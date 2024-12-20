package com.projet.pfa.controller;

import com.projet.pfa.entities.IdCardDetails;
import com.projet.pfa.services.OcrService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/ocr")
public class OcrController {

    private final OcrService ocrService;

    public OcrController(OcrService ocrService) {
        this.ocrService = ocrService;
    }

    /**
     * Endpoint to upload an image, extract data, and store it in the database.
     *
     * @param file the uploaded image file
     * @return ResponseEntity containing the extracted data and a success message
     */
    @PostMapping("/upload")
    public ResponseEntity<?> uploadImageAndExtractData(@RequestParam("file") MultipartFile file) {
        try {
            // Extract data from the uploaded image
            Map<String, String> extractedData = ocrService.extractDataFromImage(file);

            // Save the extracted data to the database
            IdCardDetails savedData = ocrService.saveExtractedData(extractedData);

            // Return response with the extracted data
            return ResponseEntity.ok(savedData);

        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("An error occurred while processing the image: " + e.getMessage());
        }
    }
}
