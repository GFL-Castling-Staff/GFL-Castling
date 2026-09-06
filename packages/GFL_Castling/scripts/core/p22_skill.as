#include "helpers.as"
#include "GFLparameters.as"

const int P22_SUPPORT_INVALID = -1;
const int P22_SUPPORT_REPAIR = 0;
const int P22_SUPPORT_SUPPLY = 1;
const int P22_SUPPORT_SMOKE = 2;

// A is the first aim point, P the CURRENT caster position, B the second aim point.
// Only X/Z matter. A is the intended target; B only selects a branch relative to P->A.
int selectP22Support(Vector3 playerPos, Vector3 firstTarget, Vector3 secondTarget) {
    float dx = secondTarget.m_values[0] - firstTarget.m_values[0];
    float dz = secondTarget.m_values[2] - firstTarget.m_values[2];
    // A fixed circle around A, independent of caster distance or facing.
    // A tiny squared-distance tolerance keeps the inclusive edge stable in floats.
    if (dx * dx + dz * dz <= P22_CENTER_RADIUS * P22_CENTER_RADIUS + 0.0001f) {
        return P22_SUPPORT_REPAIR;
    }

    float fx = firstTarget.m_values[0] - playerPos.m_values[0];
    float fz = firstTarget.m_values[2] - playerPos.m_values[2];
    float sx = secondTarget.m_values[0] - playerPos.m_values[0];
    float sz = secondTarget.m_values[2] - playerPos.m_values[2];
    float forwardLengthSq = fx * fx + fz * fz;
    float secondLengthSq = sx * sx + sz * sz;
    if (forwardLengthSq < 0.01f || secondLengthSq < 0.01f) return P22_SUPPORT_INVALID;

    float left = fz * sx - fx * sz;
    if (left * left <= 0.000001f * forwardLengthSq * secondLengthSq) return P22_SUPPORT_INVALID;
    return left > 0.0f ? P22_SUPPORT_SUPPLY : P22_SUPPORT_SMOKE;
}

bool isP22TargetInRange(Vector3 playerPos, Vector3 target) {
    float dx = target.m_values[0] - playerPos.m_values[0];
    float dz = target.m_values[2] - playerPos.m_values[2];
    return dx * dx + dz * dz <= P22_CAST_RANGE * P22_CAST_RANGE;
}

// One short-lived selection per player; no global per-skill tracker or scan loop.
class P22SkillSelection {
    int m_characterId;
    int m_factionId;
    Vector3 m_target;
    bool m_active = true;

    P22SkillSelection(int characterId, int factionId, Vector3 target) {
        m_characterId = characterId;
        m_factionId = factionId;
        m_target = target;
    }
}
