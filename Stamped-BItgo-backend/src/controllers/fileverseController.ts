import { Request, Response } from 'express';
import { FileverseService } from '../services/fileverseService';

export class FileverseController {
  private fileverseService: FileverseService;

  constructor() {
    this.fileverseService = new FileverseService();
  }

  public createFileverseDoc = async (req: Request, res: Response): Promise<void> => {
    try {
      console.log(`[DEBUG] Received Fileverse request:`, JSON.stringify(req.body).substring(0, 200) + '...');
      const { title, content } = req.body;

      if (!title || typeof title !== 'string') {
        res.status(400).json({ error: 'Missing or invalid title' });
        return;
      }

      if (!content || typeof content !== 'string') {
        res.status(400).json({ error: 'Missing or invalid content' });
        return;
      }

      // 1. Create document
      const result = await this.fileverseService.createDocument(title, content);
      const docId = result.documentId || result.ddocId || result.id;

      if (!docId) {
          throw new Error("Document ID not returned from Fileverse");
      }

      // 2. Poll for the valid official link
      let shareableLink = null;
      let attempts = 0;
      console.log(`[INFO] Polling for official shareable link for document ${docId}...`);
      
      while (!shareableLink && attempts < 20) {
          attempts++;
          try {
              const docData = await this.fileverseService.getDocument(docId);
              if (docData.link) {
                  shareableLink = docData.link;
                  console.log(`[SUCCESS] Official link acquired on attempt ${attempts}: ${shareableLink}`);
                  break;
              } else {
                  console.log(`[DEBUG] Attempt ${attempts}: Link not ready, syncStatus: ${docData.syncStatus}`);
              }
          } catch (linkError: any) {
              console.warn(`[WARN] Attempt ${attempts}: Error fetching metadata: ${linkError.message}`);
          }
          
          if (!shareableLink) {
              await new Promise(resolve => setTimeout(resolve, 3000)); // wait 3 seconds
          }
      }

      if (!shareableLink) {
          console.error(`[ERROR] Timeout waiting for shareable link for ${docId}`);
          res.status(504).json({ error: 'Timeout waiting for Fileverse sync' });
          return;
      }
      
      res.status(200).json({
        ...result,
        shareableLink
      });

    } catch (error: any) {
      console.error(`[ERROR] Fileverse creation failed:`, error.message);
      res.status(500).json({ error: 'Failed to create Fileverse document' });
    }
  };

  /**
   * Endpoint for the frontend to poll for document sync status and link
   */
  public getFileverseDocStatus = async (req: Request, res: Response): Promise<void> => {
    try {
      const { docId } = req.params;
      
      if (!docId) {
        res.status(400).json({ error: 'Missing document ID' });
        return;
      }

      const docData = await this.fileverseService.getDocument(docId);
      
      res.status(200).json({
        ddocId: docId,
        syncStatus: docData.syncStatus || 'pending',
        link: docData.link || null
      });

    } catch (error: any) {
      console.error(`[ERROR] Failed to fetch Fileverse doc status:`, error.message);
      res.status(500).json({ error: 'Failed to fetch document status' });
    }
  };

  /**
   * Update an existing Fileverse document
   */
  public updateFileverseDoc = async (req: Request, res: Response): Promise<void> => {
    try {
      const { docId } = req.params;
      const { content, title } = req.body;

      if (!docId) {
        res.status(400).json({ error: 'Missing document ID' });
        return;
      }

      if (!content || typeof content !== 'string') {
        res.status(400).json({ error: 'Missing or invalid content' });
        return;
      }

      console.log(`[INFO] Updating Fileverse document: ${docId}`);
      const result = await this.fileverseService.updateDocument(docId, content, title);

      // Poll for new link after update
      let shareableLink = null;
      let attempts = 0;
      while (!shareableLink && attempts < 20) {
        attempts++;
        try {
          const docData = await this.fileverseService.getDocument(docId);
          if (docData.link) {
            shareableLink = docData.link;
            break;
          }
        } catch (linkError: any) {
          console.warn(`[WARN] Link poll attempt ${attempts}: ${linkError.message}`);
        }
        await new Promise(resolve => setTimeout(resolve, 3000));
      }

      res.status(200).json({
        ...result,
        shareableLink: shareableLink || null,
        ddocId: docId
      });

    } catch (error: any) {
      console.error(`[ERROR] Fileverse update failed:`, error.message);
      res.status(500).json({ error: 'Failed to update Fileverse document' });
    }
  };
}
