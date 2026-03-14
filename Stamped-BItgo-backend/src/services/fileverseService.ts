import { config } from '../config/bitgoConfig';

export class FileverseService {
  private readonly baseUrl = config.fileverseServerUrl;
  private readonly apiKey = config.fileverseApiKey;

  /**
   * Create a new dDoc on Fileverse
   */
  public async createDocument(title: string, content: string): Promise<any> {
    try {
      console.log(`[INFO] Creating Fileverse document: ${title}`);
      const url = `${this.baseUrl}/api/ddocs?apiKey=${this.apiKey}`;
      
      console.log(`[DEBUG] Sending POST request to: ${url.replace(this.apiKey, '***')}`);
      
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, content })
      });

      console.log(`[DEBUG] Received response with status: ${response.status}`);

      if (response.ok) {
        const data = await response.json();
        const docId = data.data?.documentId || data.data?.ddocId || data.id || data.documentId;
        console.log(`[SUCCESS] Fileverse document created with ID: ${docId}`);
        return data.data || data;
      } else {
        const errorText = await response.text();
        console.error(`[ERROR] Fileverse Create API Failed:`, errorText);
        throw new Error(`Failed to create Fileverse doc: ${errorText}`);
      }
    } catch (error: any) {
      console.error(`[ERROR] Fileverse Create Service Error:`, error.message);
      throw error;
    }
  }
  
  /**
   * Get document metadata including the official link
   */
  public async getDocument(documentId: string): Promise<any> {
    const url = `${this.baseUrl}/api/ddocs/${documentId}?apiKey=${this.apiKey}`;
    const response = await fetch(url);
    if (response.ok) {
        return await response.json();
    } else {
        const errorText = await response.text();
        throw new Error(`Failed to fetch document ${documentId}: ${errorText}`);
    }
  }

  /**
   * Poll for sync status until "synced"
   */
  public async waitForSync(documentId: string): Promise<void> {
    console.log(`[INFO] Polling sync status for document: ${documentId}`);
    const url = `${this.baseUrl}/api/ddocs/${documentId}?apiKey=${this.apiKey}`;
    
    const maxRetries = 30; // 30 retries * 2 seconds = 60 seconds max
    const interval = 2000;

    for (let i = 0; i < maxRetries; i++) {
        try {
            const response = await fetch(url);
            
            if (response.ok) {
                const data = await response.json();
                const status = (data.data || data)?.syncStatus;
                console.log(`[DEBUG] Sync status attempt ${i+1}: ${status}`);

                if (status === 'synced') {
                    console.log(`[SUCCESS] Document ${documentId} is synced!`);
                    return;
                }
            } else {
              console.warn(`[WARN] Sync poll attempt ${i+1} failed with status: ${response.status}`);
            }
        } catch (error: any) {
            console.warn(`[WARN] Sync poll attempt ${i+1} failed:`, error.message);
        }
        
        await new Promise(resolve => setTimeout(resolve, interval));
    }

    throw new Error(`Timeout waiting for document ${documentId} to sync.`);
  }

  /**
   * Update an existing dDoc on Fileverse
   */
  public async updateDocument(documentId: string, content: string, title?: string): Promise<any> {
    try {
      console.log(`[INFO] Updating Fileverse document: ${documentId}`);
      const url = `${this.baseUrl}/api/ddocs/${documentId}?apiKey=${this.apiKey}`;
      
      const body: any = { content };
      if (title) body.title = title;
      
      const response = await fetch(url, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });

      if (response.ok) {
        const data = await response.json();
        console.log(`[SUCCESS] Fileverse document ${documentId} updated`);
        return data.data || data;
      } else {
        const errorText = await response.text();
        console.error(`[ERROR] Fileverse Update API Failed:`, errorText);
        throw new Error(`Failed to update Fileverse doc: ${errorText}`);
      }
    } catch (error: any) {
      console.error(`[ERROR] Fileverse Update Service Error:`, error.message);
      throw error;
    }
  }
}
