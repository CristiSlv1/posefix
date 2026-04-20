package com.cristislv1.backend.weight;

import com.cristislv1.backend.auth.SupabaseAuthService;
import com.cristislv1.backend.profile.Profile;
import com.cristislv1.backend.profile.ProfileRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/weights")
public class WeightHistoryController {

    private final WeightHistoryRepository weightRepo;
    private final ProfileRepository profileRepo;

    public WeightHistoryController(WeightHistoryRepository weightRepo, ProfileRepository profileRepo) {
        this.weightRepo = weightRepo;
        this.profileRepo = profileRepo;
    }

    @GetMapping
    public List<WeightHistory> getRecentWeights(@AuthenticationPrincipal SupabaseAuthService.SupabaseUser user) {
        UUID userId = UUID.fromString(user.id());
        return weightRepo.findTop30ByUserIdOrderByMeasuredOnDesc(userId);
    }

    @PutMapping("/today")
    public WeightHistory logWeightToday(
            @AuthenticationPrincipal SupabaseAuthService.SupabaseUser user,
            @Valid @RequestBody AddWeightRequest request) {

        UUID userId = UUID.fromString(user.id());
        LocalDate today = LocalDate.now();

        // 1) Upsert the daily record
        WeightHistory entry = weightRepo.findByUserIdAndMeasuredOn(userId, today)
                .orElseGet(() -> {
                    WeightHistory newEntry = new WeightHistory();
                    newEntry.setUserId(userId);
                    newEntry.setMeasuredOn(today);
                    newEntry.setSource("manual");
                    return newEntry;
                });

        entry.setWeightKg(request.getWeightKg());
        WeightHistory savedEntry = weightRepo.save(entry);

        // 2) Keep the main Profile in sync
        Profile profile = profileRepo.findById(userId).orElseGet(() -> {
            Profile p = new Profile();
            p.setUserId(userId);
            return p;
        });
        profile.setWeightKg(request.getWeightKg());
        profileRepo.save(profile);

        return savedEntry;
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteWeight(
            @AuthenticationPrincipal SupabaseAuthService.SupabaseUser user,
            @PathVariable Long id) {

        UUID userId = UUID.fromString(user.id());
        WeightHistory entry = weightRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Entry not found"));

        if (!entry.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not your entry");
        }
        weightRepo.delete(entry);
        return ResponseEntity.noContent().build();
    }
}
