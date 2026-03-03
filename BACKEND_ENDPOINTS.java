# ═══════════════════════════════════════════════════════════════════════════════
# ENDPOINTS À AJOUTER AU BACKEND
# ═══════════════════════════════════════════════════════════════════════════════

# ── 1. auth-service : Login Chef de Ménage ──────────────────────────────────
# Fichier : AuthController.java

@PostMapping("/chef/login")
public ResponseEntity<ChefLoginResponse> loginChef(@RequestBody ChefLoginRequest request) {
    return ResponseEntity.ok(authService.loginChef(request));
}

# ── DTO ChefLoginRequest ─────────────────────────────────────────────────────
public class ChefLoginRequest {
    private String nomComplet;  // Nom saisi par le chef
    private String cni;         // Numéro CNI
}

# ── DTO ChefLoginResponse ────────────────────────────────────────────────────
public class ChefLoginResponse {
    private String token;
    private String chefId;
    private String menageId;
    private String nomComplet;
    private String role = "CHEF_MENAGE";
}

# ── AuthService.loginChef() ──────────────────────────────────────────────────
public ChefLoginResponse loginChef(ChefLoginRequest request) {
    // 1. Chercher le résident par nom + CNI + estChef = true
    Resident chef = residentRepository
        .findByNomCompletIgnoreCaseAndCniAndEstChefTrue(
            request.getNomComplet(), request.getCni()
        )
        .orElseThrow(() -> new UnauthorizedException("NOM ou CNI incorrect"));

    // 2. Générer JWT avec rôle CHEF_MENAGE
    String token = jwtService.generateToken(chef.getId().toString(), "CHEF_MENAGE", chef.getMenageId().toString());

    return ChefLoginResponse.builder()
        .token(token)
        .chefId(chef.getId().toString())
        .menageId(chef.getMenageId().toString())
        .nomComplet(chef.getPrenom() + " " + chef.getNom())
        .role("CHEF_MENAGE")
        .build();
}

# ── Repository — requête ─────────────────────────────────────────────────────
# ResidentRepository.java
Optional<Resident> findByNomCompletIgnoreCaseAndCniAndEstChefTrue(String nomComplet, String cni);

# NOTE : si la table résidents stocke nom et prénom séparément,
# utilisez une @Query JPQL :
@Query("SELECT r FROM Resident r WHERE LOWER(CONCAT(r.prenom, ' ', r.nom)) = LOWER(:nomComplet) AND r.cni = :cni AND r.estChef = true")
Optional<Resident> findChefByNomAndCni(@Param("nomComplet") String nomComplet, @Param("cni") String cni);


# ═══════════════════════════════════════════════════════════════════════════════
# ── 2. main-service : Endpoints pour le Chef connecté ──────────────────────
# Fichier : ChefMenageController.java
# ═══════════════════════════════════════════════════════════════════════════════

@RestController
@RequestMapping("/api/v1/chef")
@PreAuthorize("hasRole('CHEF_MENAGE')")
public class ChefMenageController {

    # GET /api/v1/chef/menage → infos du ménage du chef connecté
    @GetMapping("/menage")
    public ResponseEntity<MenageResponse> getMonMenage(@AuthenticationPrincipal Jwt jwt) {
        UUID menageId = UUID.fromString(jwt.getClaim("menageId"));
        return ResponseEntity.ok(menageService.getMenageById(menageId));
    }

    # GET /api/v1/chef/residents → résidents du ménage
    @GetMapping("/residents")
    public ResponseEntity<List<ResidentResponse>> getMesResidents(@AuthenticationPrincipal Jwt jwt) {
        UUID menageId = UUID.fromString(jwt.getClaim("menageId"));
        return ResponseEntity.ok(residentService.getResidentsByMenage(menageId));
    }

    # GET /api/v1/chef/scoring → catégorie sociale (appel scoring-service)
    @GetMapping("/scoring")
    public ResponseEntity<ScoringResponse> getMonScore(@AuthenticationPrincipal Jwt jwt) {
        UUID menageId = UUID.fromString(jwt.getClaim("menageId"));
        return ResponseEntity.ok(scoringClient.getLatestScore(menageId));
    }
}

# ── Route API Gateway à ajouter ──────────────────────────────────────────────
# Dans docker-compose.yml, section api-gateway environment :
- SPRING_CLOUD_GATEWAY_ROUTES[6]_ID=chef-endpoints
- SPRING_CLOUD_GATEWAY_ROUTES[6]_URI=lb://MAIN-SERVICE
- SPRING_CLOUD_GATEWAY_ROUTES[6]_PREDICATES[0]=Path=/api/main/chef/**
- SPRING_CLOUD_GATEWAY_ROUTES[6]_FILTERS[0]=StripPrefix=1
