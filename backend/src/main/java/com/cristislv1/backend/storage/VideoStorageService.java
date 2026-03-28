package com.cristislv1.backend.storage;

import org.springframework.web.multipart.MultipartFile;
import java.util.UUID;

public interface VideoStorageService {
    String storeVideo(Long workoutId, UUID userId, MultipartFile file);
}
