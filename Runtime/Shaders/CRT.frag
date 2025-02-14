// START of section borrowed from https://www.shadertoy.com/view/XsjSzR by Timothy Lottes
// Emulated input resolution.
#if 0
  // Fix resolution to set amount.
  #define res (vec2(320.0/1.0,160.0/1.0))
#else
  // Optimize for resize.
  #define res (iResolution.xy/6.0)
#endif

// sRGB to Linear.
// Assuming using sRGB typed textures this should not be needed.
float ToLinear1(float c) {
    return(c <= 0.04045) ? c / 12.92 : pow((c + 0.055) / 1.055,2.4);
}
vec3 ToLinear(vec3 c) {
    return vec3(ToLinear1(c.r), ToLinear1(c.g), ToLinear1(c.b));
}

// Linear to sRGB.
// Assuing using sRGB typed textures this should not be needed.
float ToSrgb1(float c) {
    return(c < 0.0031308 ? c * 12.92 : 1.055 * pow(c, 0.41666) - 0.055);
}
vec3 ToSrgb(vec3 c) {
    return vec3(ToSrgb1(c.r), ToSrgb1(c.g), ToSrgb1(c.b));
}

// Nearest emulated sample given floating point position and texel offset.
// Also zero's off screen.
vec3 Fetch(vec2 pos, vec2 off) {
  pos = floor(pos * res + off) / res;
  
  if(max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5){
      return vec3(0.0, 0.0, 0.0);
  }
  
  return ToLinear(texture(iChannel0, pos.xy, -16.0).rgb);
}
// END of section borrowed from https://www.shadertoy.com/view/XsjSzR by Timothy Lottes

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    fragColor.rgb = Fetch(uv, vec2(0.0,0.0));
    
    vec4 color = vec4(ToSrgb(fragColor.rgb), 1.0);

    int fragX = int(floor(fragCoord.x));
    int fragY = int(floor(fragCoord.y));

    int columnMod = fragX % 6;
    int xMod = columnMod % 3;
    int yMod = fragY % 6;

    bool primaryColumn = columnMod < 3;

    if(xMod == 0)      color = vec4(color.r, 0.0f, 0.0f, 1.0f);
    else if(xMod == 1) color = vec4(0.0f, color.g, 0.0f, 1.0f);
    else if(xMod == 2) color = vec4(0.0f, 0.0f, color.b, 1.0f);
    else if(xMod == 3) color = vec4(0.0f, 0.0f, 0.0f, 1.0f);

    if(primaryColumn)
    {
        if (yMod == 2) color = vec4(0.0f, 0.0f, 0.0f, 1.0f);
    }
    else
    {
        if (yMod == 5) color = vec4(0.0f, 0.0f, 0.0f, 1.0f);
    }

    // Output to screen
    fragColor = vec4(color);
}