set(component_srcs)

idf_component_register(SRCS "mqtt.c"  "${component_srcs}"       
                     REQUIRES esp_event esp_netif lwip mqtt esp_wifi json WiFi
                       INCLUDE_DIRS ".")
