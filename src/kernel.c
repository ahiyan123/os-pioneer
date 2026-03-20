#include <stdint.h>

// --- OS CONSTANTS & APP STATES ---
#define VIDEO_MEM 0xB8000
#define LIGHTPAD 1
#define APPEL    2
#define OUTVIE   3
#define PRESENTU 4
#define EXPLORE  5
int current_app = EXPLORE;

// --- HARDWARE I/O ---
void outb(uint16_t p, uint8_t v)  { asm volatile("outb %0, %1"::"a"(v),"Nd"(p)); }
void outl(uint16_t p, uint32_t v) { asm volatile("outl %0, %1"::"a"(v),"Nd"(p)); }
uint8_t inb(uint16_t p)           { uint8_t r; asm volatile("inb %1, %0":"=a"(r):"Nd"(p)); return r; }
uint32_t inl(uint16_t p)          { uint32_t r; asm volatile("inl %1, %0":"=a"(r):"Nd"(p)); return r; }

// --- PCI & NETWORK (RTL8139) ---
uint32_t io_base;
void init_network() {
    for(int bus=0; bus<256; bus++) {
        for(int slot=0; slot<32; slot++) {
            // Check Vendor 0x10EC, Device 0x8139
            uint32_t id = (uint32_t)0x80000000 | (bus << 16) | (slot << 11);
            outl(0xCF8, id);
            if(inl(0xCFC) == 0x813910EC) {
                outl(0xCF8, id | 0x10); // BAR0
                io_base = inl(0xCFC) & ~0x1;
                outb(io_base + 0x52, 0x00); // Power on
                outb(io_base + 0x37, 0x10); // Reset
                outb(io_base + 0x37, 0x0C); // Enable TX/RX
                return;
            }
        }
    }
}

// --- UI ENGINE ---
void print(char* s, int x, int y, char color) {
    char* v = (char*)(VIDEO_MEM + (y * 160) + (x * 2));
    while(*s) { *v++ = *s++; *v++ = color; }
}

void draw_rect(int x, int y, int w, int h, char color) {
    for(int i=y; i<y+h; i++) {
        for(int j=x; j<x+w; j++) {
            char* v = (char*)(VIDEO_MEM + (i * 160) + (j * 2));
            *v = ' '; *(v+1) = color;
        }
    }
}

// --- THE 5 SOVEREIGN APPS ---
void run_lightpad() {
    draw_rect(0, 0, 80, 25, 0x1F); // Blue
    print(" [ LightPad ] - Private Text Editor ", 1, 0, 0x70);
    print(" > Pioneer doesn't know to rest. ", 2, 2, 0x1F);
}

void run_appel() {
    draw_rect(0, 0, 80, 25, 0x70); // White Paper
    print(" [ Appel ] - Sovereign Word Processor ", 20, 0, 0x0F);
    print("---------------------------------------", 20, 1, 0x07);
}

void run_outvie() {
    draw_rect(0, 0, 80, 25, 0x2F); // Green Grid
    print(" [ OutVie ] - No-Tracker Spreadsheet ", 1, 0, 0x0F);
    for(int i=2; i<20; i+=2) print("|________|________|________|________|", 5, i, 0x2F);
}

void run_presentu() {
    draw_rect(0, 0, 80, 25, 0x4F); // Red/Maroon
    print(" [ PresentU ] ", 33, 10, 0x4F);
    print(" Slide 1: Everyone isn't same. ", 25, 12, 0x4F);
}

void run_explorefile() {
    draw_rect(0, 0, 80, 25, 0x07); // Gray/Black
    print(" [ ExploreFile ] - Search DuckDuckGo (S) ", 0, 0, 0x3F);
    print(" > kernel.bin [512B] ", 2, 2, 0x07);
    if(io_base) print(" NIC: RTL8139 READY ", 55, 0, 0x2F);
}

// --- APP SWITCHER ---
void refresh_system() {
    if(current_app == LIGHTPAD) run_lightpad();
    else if(current_app == APPEL)    run_appel();
    else if(current_app == OUTVIE)   run_outvie();
    else if(current_app == PRESENTU) run_presentu();
    else run_explorefile();
    print(" 1:LP 2:AP 3:OV 4:PU 5:EX ", 25, 24, 0x0E);
}

// --- KERNEL ENTRY ---
void kernel_main() {
    init_network();
    refresh_system();
    
    while(1) {
        uint8_t sc = inb(0x60); // Read Keyboard
        if(sc >= 0x02 && sc <= 0x06) { // Keys 1-5
            current_app = sc - 0x01;
            refresh_system();
            for(int i=0; i<1000000; i++); // Tiny delay
        }
    }
}
