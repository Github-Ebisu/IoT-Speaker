#include "driver/gpio.h"
#include "wifi.h"
#include "nvs_flash.h"
#include "DFPlayer.h"
#include "ssd1306.h"

#define TXD_PIN (GPIO_NUM_17)
#define RXD_PIN (GPIO_NUM_16)
#define UART UART_NUM_2

static const int RX_BUF_SIZE = 1024;
uint32_t MQTT_CONNECTED = 0;
DFPLAYER_Name MP3;
DFPLAYER_Control DFControl;
SSD1306_t dev;
int page = 0;
void init_uart(DFPLAYER_Name *MP3)
{
    const uart_config_t uart_config = {
        .baud_rate = 9600,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_APB,
    };
    // We won't use a buffer for sending data.
    ESP_ERROR_CHECK(uart_driver_install(MP3->DFP_UART, RX_BUF_SIZE * 2, 0, 0, NULL, 0));
    ESP_ERROR_CHECK(uart_param_config(MP3->DFP_UART, &uart_config));
    ESP_ERROR_CHECK(uart_set_pin(MP3->DFP_UART, TXD_PIN, RXD_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE));
}
void initOLED()
{
    i2c_master_init(&dev, CONFIG_SDA_GPIO, CONFIG_SCL_GPIO, CONFIG_RESET_GPIO);
    ssd1306_init(&dev, 128, 64);
    ssd1306_clear_screen(&dev, false);
    ssd1306_contrast(&dev, 0xff);
}
static void rx_task(void *arg)
{
    static const char *RX_TASK_TAG = "RX_TASK";
    esp_log_level_set(RX_TASK_TAG, ESP_LOG_INFO);
    uint8_t *data = (uint8_t *)malloc(10);
    while (1)
    {
        const int rxBytes = uart_read_bytes(UART, data, 10, 500 / portTICK_PERIOD_MS);
        if (rxBytes > 0)
        {
            data[rxBytes] = 0;
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[0]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[1]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[2]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[3]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[4]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[5]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[6]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[7]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[8]);
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%02X'", rxBytes, data[9]);
        }
    }
    free(data);
}

void app_main(void)
{

    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND)
    {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    wifi_init_sta();
    mqtt_data_pt_set_callback(mqtt_get_data_callback);
    DFPLAYER_Init(&MP3, UART_NUM_2);
    // initOLED();
    init_uart(&MP3);
    vTaskDelay(20 / portTICK_PERIOD_MS);
    xTaskCreate(rx_task, "rx_task", 1024 * 2, NULL, configMAX_PRIORITIES - 1, NULL);
    vTaskDelay(20 / portTICK_PERIOD_MS);
    while (true)
    {
        vTaskDelay(20 / portTICK_PERIOD_MS);
    }
}
