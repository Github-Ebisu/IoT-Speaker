set(component_srcs)

idf_component_register(SRCS "wifi.c" "${component_srcs}"
                    REQUIRES esp_event esp_netif lwip esp_wifi MQTT_PUB_SUB SSD1306
                       INCLUDE_DIRS "." )
