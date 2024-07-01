#ifndef _WIFI_H
#define _WIFI_H

#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"

#include "lwip/err.h"
#include "lwip/sys.h"

#include "mqtt.h"
#include "ssd1306.h"
// #define EXAMPLE_ESP_WIFI_SSID "KTMT - SinhVien"
// #define EXAMPLE_ESP_WIFI_PASS "sinhvien"
#define EXAMPLE_ESP_WIFI_SSID "Ebisu"
#define EXAMPLE_ESP_WIFI_PASS "matmapassword"
#define EXAMPLE_ESP_MAXIMUM_RETRY 50
#define WIFI_AUTH_WPA2_PSK 1
extern SSD1306_t dev;
extern int page;
void wifi_event_handler(void *arg, esp_event_base_t event_base,
                        int32_t event_id, void *event_data);

void wifi_init_sta(void);

#endif // MACRO
