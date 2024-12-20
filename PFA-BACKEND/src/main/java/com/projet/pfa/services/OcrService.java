package com.projet.pfa.services;

import com.projet.pfa.entities.IdCardDetails;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

public interface OcrService {
    Map<String, String> extractDataFromImage(MultipartFile file);
    IdCardDetails saveExtractedData(Map<String, String> extractedData);
}
