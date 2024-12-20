package com.projet.pfa.services.impl;

import com.projet.pfa.entities.IdCardDetails;
import com.projet.pfa.repository.IdCardDetailsRepository;
import com.projet.pfa.services.OcrService;
import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class OcrServiceImpl implements OcrService {

    @Value("${tesseract.datapath}")
    private String tesseractDataPath;

    private final IdCardDetailsRepository idCardDetailsRepository;

    public OcrServiceImpl(IdCardDetailsRepository idCardDetailsRepository) {
        this.idCardDetailsRepository = idCardDetailsRepository;
    }

    @Override
    public Map<String, String> extractDataFromImage(MultipartFile file) {
        Tesseract tesseract = new Tesseract();
        tesseract.setDatapath(tesseractDataPath);
        tesseract.setLanguage("eng");

        Map<String, String> extractedData = new HashMap<>();
        try {
            // Save the file temporarily
            File tempFile = File.createTempFile("uploaded-", file.getOriginalFilename());
            file.transferTo(tempFile);

            // Perform OCR
            String result = tesseract.doOCR(tempFile);

            // Regular expressions for field extraction
            String namePattern = "Name:\\s*(.+)";
            String idPattern = "ID:\\s*(\\S+)";
            String dobPattern = "DOB:\\s*([\\d-]+)";
            String addressPattern = "Address:\\s*(.+)";

            // Extract fields using regex
            extractedData.put("full_name", extractUsingRegex(result, namePattern));
            extractedData.put("id_number", extractUsingRegex(result, idPattern));
            extractedData.put("date_of_birth", extractUsingRegex(result, dobPattern));
            extractedData.put("address", extractUsingRegex(result, addressPattern));

            // Clean up the temporary file
            tempFile.delete();
        } catch (IOException | TesseractException e) {
            throw new RuntimeException("Failed to process the image", e);
        }
        return extractedData;
    }

    @Override
    public IdCardDetails saveExtractedData(Map<String, String> extractedData) {
        IdCardDetails idCardDetails = new IdCardDetails();
        idCardDetails.setFullName(extractedData.get("full_name"));
        idCardDetails.setIdNumber(extractedData.get("id_number"));
        idCardDetails.setDateOfBirth(extractedData.get("date_of_birth"));
        idCardDetails.setAddress(extractedData.get("address"));

        return idCardDetailsRepository.save(idCardDetails);
    }

    private String extractUsingRegex(String text, String regex) {
        Pattern pattern = Pattern.compile(regex, Pattern.MULTILINE);
        Matcher matcher = pattern.matcher(text);
        return matcher.find() ? matcher.group(1).trim() : null;
    }
}
