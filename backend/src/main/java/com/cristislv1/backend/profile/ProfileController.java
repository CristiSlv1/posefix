package com.cristislv1.backend.profile;

import com.cristislv1.backend.auth.SupabaseAuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

@RestController
@RequestMapping("/profile")
public class ProfileController {

    private final ProfileRepository profileRepository;

    public ProfileController(ProfileRepository profileRepository) {
        this.profileRepository = profileRepository;
    }

    @GetMapping
    public Profile getProfile(@AuthenticationPrincipal SupabaseAuthService.SupabaseUser user) {
        UUID userId = UUID.fromString(user.id());
        return profileRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Profile not found"));
    }

    @PutMapping
    public Profile updateProfile(
            @AuthenticationPrincipal SupabaseAuthService.SupabaseUser user,
            @Valid @RequestBody UpdateProfileRequest request) {

        UUID userId = UUID.fromString(user.id());

        Profile profile = profileRepository.findById(userId).orElse(new Profile());

        // If it's a new profile, we make sure the ID is set
        if (profile.getUserId() == null) {
            profile.setUserId(userId);
        }

        profile.setName(request.getName());
        profile.setBirthDate(request.getBirthDate());
        profile.setWeightKg(request.getWeightKg());
        profile.setHeightCm(request.getHeightCm());
        profile.setSex(request.getSex());

        return profileRepository.save(profile);
    }
}
