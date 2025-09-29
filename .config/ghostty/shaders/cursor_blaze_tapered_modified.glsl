// Taken from https://github.com/KroneCorylus/ghostty-shader-playground/tree/main and modified to not show a "glow effect"

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}


vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}
float ease(float x) {
    return pow(1.0 - x, 3.0);
}

//const vec4 TRAIL_COLOR = vec4(1.0, 0.725, 0.161, 1.0);
// Use current cursor color for trail to match cursor appearance
vec4 TRAIL_COLOR = iCurrentCursorColor;
const float DURATION = 0.3; //IN SECONDS

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    // Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    // Normalization for cursor position and size;
    // cursor xy has the postion in a space of -1 to 1;
    // zw has the width and height
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);

    // Calculate movement distance and direction to determine if trail should be shown
    // Only show trail for navigation movements, not during normal typing
    vec2 movementVector = centerCC - centerCP;
    float horizontalMovement = abs(movementVector.x);
    float verticalMovement = abs(movementVector.y);

    // Calculate full character cell dimensions assuming 2:1 height-to-width ratio
    // This works regardless of cursor shape (block, vertical line, horizontal line)
    float charWidth = max(currentCursor.z, currentCursor.w / 2.0);
    float charHeight = max(currentCursor.w, currentCursor.z * 2.0);

    // Define thresholds based on character cell size in normalized coordinates
    // This automatically scales with both font size and terminal dimensions
    float charThresholdH = charWidth * 1.5; // 1.5 character widths
    float charThresholdV = charHeight * 1.5; // 1.5 character heights

    // Only show trail if movement exceeds character-based thresholds
    // This prevents trail from showing during normal typing regardless of window size
    float shouldShowTrail = step(charThresholdV, verticalMovement) + step(charThresholdH, horizontalMovement);
    shouldShowTrail = min(shouldShowTrail, 1.0); // Clamp to 1.0

    // TRAIL PARALLELOGRAM CONSTRUCTION:
    // Create a perfect parallelogram by connecting corresponding edges of both cursors.
    // The parallelogram connects the edge of the previous cursor that faces the movement direction
    // to the edge of the current cursor that faces back toward the previous position.
    //
    // Algorithm:
    // 1. Determine primary movement direction (horizontal vs vertical)
    // 2. For each cursor, identify the two corner points on the edge facing the other cursor
    // 3. Connect these edges to form a proper parallelogram
    //
    // This ensures the trail appears centered and seamlessly connects both cursor positions
    // regardless of movement direction or cursor shape (block, line, etc.)

    vec2 movement = centerCC - centerCP;
    float absHorizontal = abs(movement.x);
    float absVertical = abs(movement.y);

    // Determine if movement is primarily horizontal (1.0) or vertical (0.0)
    float isHorizontalPrimary = step(absVertical, absHorizontal);

    // Calculate cursor corner coordinates
    // Previous cursor corners
    vec2 prevTopLeft = vec2(previousCursor.x, previousCursor.y);
    vec2 prevTopRight = vec2(previousCursor.x + previousCursor.z, previousCursor.y);
    vec2 prevBottomLeft = vec2(previousCursor.x, previousCursor.y - previousCursor.w);
    vec2 prevBottomRight = vec2(previousCursor.x + previousCursor.z, previousCursor.y - previousCursor.w);

    // Current cursor corners
    vec2 currTopLeft = vec2(currentCursor.x, currentCursor.y);
    vec2 currTopRight = vec2(currentCursor.x + currentCursor.z, currentCursor.y);
    vec2 currBottomLeft = vec2(currentCursor.x, currentCursor.y - currentCursor.w);
    vec2 currBottomRight = vec2(currentCursor.x + currentCursor.z, currentCursor.y - currentCursor.w);

    // Select connecting edges based on movement direction
    vec2 prevEdge1, prevEdge2, currEdge1, currEdge2;

    if (isHorizontalPrimary > 0.5) {
        // Horizontal movement: connect vertical edges
        if (movement.x > 0.0) {
            // Moving right: connect previous right edge to current left edge
            prevEdge1 = prevTopRight;
            prevEdge2 = prevBottomRight;
            currEdge1 = currTopLeft;
            currEdge2 = currBottomLeft;
        } else {
            // Moving left: connect previous left edge to current right edge
            prevEdge1 = prevTopLeft;
            prevEdge2 = prevBottomLeft;
            currEdge1 = currTopRight;
            currEdge2 = currBottomRight;
        }
    } else {
        // Vertical movement: connect horizontal edges
        if (movement.y > 0.0) {
            // Moving up: connect previous top edge to current bottom edge
            prevEdge1 = prevTopLeft;
            prevEdge2 = prevTopRight;
            currEdge1 = currBottomLeft;
            currEdge2 = currBottomRight;
        } else {
            // Moving down: connect previous bottom edge to current top edge
            prevEdge1 = prevBottomLeft;
            prevEdge2 = prevBottomRight;
            currEdge1 = currTopLeft;
            currEdge2 = currTopRight;
        }
    }

    // Create parallelogram vertices by connecting the identified edges
    vec2 v0 = prevEdge1;   // First corner of previous cursor edge
    vec2 v1 = prevEdge2;   // Second corner of previous cursor edge
    vec2 v2 = currEdge2;   // Corresponding second corner of current cursor edge
    vec2 v3 = currEdge1;   // Corresponding first corner of current cursor edge

    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    // Distance between cursors determine the total length of the parallelogram;
    float lineLength = distance(centerCC, centerCP);

    //trailblaze - render parallelogram trail with minimal anti-aliasing
    // Use very small smoothstep range (-0.001, 0.001) for subtle anti-aliasing without visible glow
    float trailAlpha = smoothstep(-0.001, 0.001, sdfTrail) * shouldShowTrail;
    vec4 trail = mix(TRAIL_COLOR, fragColor, trailAlpha);
    // Apply time-based fade-out animation to the trail
    fragColor = mix(trail, fragColor, 1. - smoothstep(0., sdfCurrentCursor, easedProgress * lineLength * shouldShowTrail));
}
