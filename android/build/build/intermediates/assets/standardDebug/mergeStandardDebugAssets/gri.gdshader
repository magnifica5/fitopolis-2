shader_type canvas_item;

uniform vec2 rect_start;
uniform vec2 rect_end;
uniform bool is_active = true;

// Folosim SCREEN_UV pentru a ignora scale-ul local al nodurilor
varying vec2 global_pos;

void vertex() {
    // Calculăm poziția relativă la "lumea" jocului, nu la nod
    global_pos = (CANVAS_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    if (is_active) {
        // Verificăm poziția globală
        if (global_pos.x >= rect_start.x && global_pos.x <= rect_end.x &&
            global_pos.y >= rect_start.y && global_pos.y <= rect_end.y) {
            
            float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
            COLOR = vec4(vec3(gray), color.a);
        } else {
            COLOR = color;
        }
    } else {
        COLOR = color;
    }
}