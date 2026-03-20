#include <stdint.h>

// Sovereign App Definitions
#define LIGHTPAD 1
#define APPEL    2
#define OUTVIE   3
#define PRESENTU 4
#define EXPLORE  5
int current_app = EXPLORE;

// FAT32 / Disk Constants (Adjusted for 1.9GB)
#define CLUSTER_BEGIN_LBA (32 + (2 * 3800))

// I/O Helpers
static inline void outb(uint16_t port, uint8_t val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static inline void outw(uint16_t port, uint16_t val) {
    asm volatile("outw %0, %1" : : "a"(val), "Nd"(port));
}

// 64-bit Aware Print Logic
void print(const char* s, int x, int y, char color) {
    // ULL suffix ensures 64-bit pointer arithmetic
    uint8_t* v = (uint8_t*)(0xB8000ULL + (y * 160) + (x * 2));
    while(*s) {
        *v++ = (uint8_t)*s++;
        *v++ = (uint8_t)color;
    }
}

void clear() {
    uint8_t* v = (uint8_t*)0xB8000ULL;
    for(int i = 0; i < 80 * 25 * 2; i += 2) {
        v[i] = ' ';
        v[i+1] = 0x07;
    }
}

// Disk Writer (ATA PIO Mode)
void disk_write(uint32_t lba, uint16_t* buffer) {
    outb(0x1F6, (uint8_t)((lba >> 24) | 0xE0));
    outb(0x1F2, 1);
    outb(0x1F3, (uint8_t)lba);
    outb(0x1F4, (uint8_t)(lba >> 8));
    outb(0x1F5, (uint8_t)(lba >> 16));
    outb(0x1F7, 0x30); // Write sectors command
    
    while (!(inb(0x1F7) & 0x08)); // Wait for DRQ
    for (int i = 0; i < 256; i++) {
        outw(0x1F0, buffer[i]);
    }
}



void refresh_ui() {
    clear();
    print(" 1:LP | 2:AP | 3:OV | 4:PU | 5:EX ", 0, 24, 0x4F);
    print(" Pioneer doesn't know to rest. ", 50, 24, 0x0E);

    switch(current_app) {
        case LIGHTPAD:
            print(" [ LightPad ] - Private Text Editor ", 0, 0, 0x1F);
            print(" Saving to FAT32 Cluster 2... ", 2, 2, 0x07);
            uint16_t note[256] = {0}; 
            disk_write(CLUSTER_BEGIN_LBA, note);
            break;
        case APPEL:
            print(" [ Appel ] - Sovereign Word Processor ", 0, 0, 0x70);
            print(" Everyone isn't same. ", 2, 2, 0x07);
            break;
        case OUTVIE:
            print(" [ OutVie ] - No-Tracker Spreadsheet ", 0, 0, 0x2F);
            print(" | C1 | C2 | C3 | ", 2, 2, 0x07);
            break;
        case PRESENTU:
            print(" [ PresentU ] - Slideshow ", 0, 0, 0x5F);
            print(" Slide 1: Escape the Product. ", 10, 10, 0x0F);
            break;
        case EXPLORE:
            print(" [ ExploreFile ] - Storage Manager ", 0, 0, 0x3F);
            print(" Total Disk Capacity: 1.9 GB ", 2, 2, 0x0A);
            print(" File System: FAT32 [ACTIVE] ", 2, 3, 0x07);
            break;
    }
}

void kernel_main() {
    refresh_ui();
    while(1) {
        uint8_t sc = inb(0x60); // Keyboard Port
        if(sc >= 0x02 && sc <= 0x06) {
            current_app = sc - 0x01;
            refresh_ui();
            // Basic debounce delay for Pioneer hardware
            for(volatile long i = 0; i < 10000000; i++); 
        }
    }
}
