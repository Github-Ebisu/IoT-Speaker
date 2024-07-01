idf_component_register(SRCS "DFPlayer.c"
                    INCLUDE_DIRS "." 
                    REQUIRES driver MQTT_PUB_SUB SSD1306)
