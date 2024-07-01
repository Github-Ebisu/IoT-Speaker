/******************************************************************************************************************
@File:  	DFPlayer Mini Module
@Author:  Khue Nguyen
@Website: khuenguyencreator.com
@Youtube: https://www.youtube.com/channel/UCt8cFnPOaHrQXWmVkk-lfvg
Huong dan su dung:
- Su dung thu vien HAL
- Khoi tao UART Baud 9600
- Khoi tao bien DFPlayer : DFPLAYER_Name MP3;
- Khoi tao DFPlayer do:
	DFPLAYER_Init(&MP3, &huart1);
- Su dung cac ham phai truyen dia chi cua DFPlayer do:
	DFPLAYER_Play(&MP3);
******************************************************************************************************************/
#include "DFPLAYER.h"
static const char *TAG = "DFPLAYER";

uint8_t SendFrame[10] = {0x7E, 0xFF, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xEF};

//******************************** LOW Level Functions ****************************//
static void DFPLAYER_SendUART(DFPLAYER_Name *MP3)
{
	uart_write_bytes(MP3->DFP_UART, (uint8_t *)&MP3->SendBuff, sizeof(MP3->SendBuff));
	ESP_LOGI("ESP32", "Send data");
	vTaskDelay(1000 / portTICK_PERIOD_MS);
	for (int i = 0; i < sizeof(MP3->SendBuff); i++)
	{
		printf("%02X ", MP3->SendBuff[i]);
	}
	printf("\n");
}
static void DFPLAYER_Delay(uint16_t Time)
{
	vTaskDelay(Time);
}

static uint16_t DFPLAYER_GetChecksum(uint8_t *thebuf)
{
	uint16_t sum = 0;
	for (int i = 1; i < 7; i++)
	{
		sum += thebuf[i];
	}
	return -sum;
}

static void DFPLAYER_FillBigend(uint8_t *thebuf, uint16_t data)
{
	*thebuf = (uint8_t)(data >> 8);
	*(thebuf + 1) = (uint8_t)data;
}

static void DFPLAYER_FillChecksum(DFPLAYER_Name *MP3)
{
	uint16_t checksum = DFPLAYER_GetChecksum(MP3->SendBuff);
	DFPLAYER_FillBigend(MP3->SendBuff + 7, checksum);
}

static void DFPLAYER_SendCmd(DFPLAYER_Name *MP3, uint8_t cmd, uint16_t high_arg, uint16_t low_arg)
{
	DFPLAYER_Delay(100);
	MP3->SendBuff[3] = cmd;
	MP3->SendBuff[5] = high_arg;
	MP3->SendBuff[6] = low_arg;
	DFPLAYER_FillChecksum(MP3);
	DFPLAYER_SendUART(MP3);
}

//******************************** High Level Functions ****************************//

void DFPLAYER_Init(DFPLAYER_Name *MP3, uart_port_t *UART)
{
	DFControl.finished = false;
	DFControl.play = false;
	DFControl.songId = -1;
	DFControl.volume = -1;
	DFControl.stop = false;
	for (int i = 0; i < 10; i++)
	{
		MP3->SendBuff[i] = SendFrame[i];
	}
	MP3->DFP_UART = UART;
}

void DFPLAYER_PlayTrack(DFPLAYER_Name *MP3, uint16_t num)
{
	uint8_t num1 = num >> 8;
	uint8_t num2 = num;
	DFPLAYER_SendCmd(MP3, DFP_PLAYTRACK, num1, num2);
}

void DFPLAYER_Next(DFPLAYER_Name *MP3)
{
	DFPLAYER_SendCmd(MP3, DFP_NEXT, 00, 00);
}

void DFPLAYER_Prev(DFPLAYER_Name *MP3)
{
	DFPLAYER_SendCmd(MP3, DFP_PREV, 00, 00);
}

void DFPLAYER_SetVolume(DFPLAYER_Name *MP3, uint16_t volume)
{
	uint8_t volume1 = volume >> 8;
	uint8_t volume2 = volume;
	DFPLAYER_SendCmd(MP3, DFP_SETVOLUME, volume1, volume2);
}

void DFPLAYER_Play(DFPLAYER_Name *MP3)
{
	DFPLAYER_SendCmd(MP3, DFP_PLAY, 00, 00);
}

void DFPLAYER_Pause(DFPLAYER_Name *MP3)
{

	DFPLAYER_SendCmd(MP3, DFP_PAUSE, 00, 00);
}

void DFPLAYER_Stop(DFPLAYER_Name *MP3)
{
	//
	DFPLAYER_SendCmd(MP3, DFP_STOP, 00, 00);
}

void DFPLAYER_RandomPlay(DFPLAYER_Name *MP3)
{
	DFPLAYER_SendCmd(MP3, DFP_RANDOM, 0, 0);
}

void DFPLAYER_PlayFileInFolder(DFPLAYER_Name *MP3, uint8_t folder, uint32_t num)
{
	DFPLAYER_SendCmd(MP3, DFP_PLAYFILEINFOLDER, folder, num);
}
void mqtt_get_data_callback(char *data, uint16_t length)
{
	int songIDRev = DFControl.songId;
	int volumeRev = DFControl.volume;
	bool finishedRev = DFControl.finished;
	bool playRev = DFControl.play;
	bool stopRev = DFControl.stop;
	// Parse JSON Data
	cJSON *root = cJSON_Parse(data);
	if (root)
	{
		// Extract Integer Values
		finishedRev = cJSON_GetObjectItem(root, "finished")->valueint;
		playRev = cJSON_GetObjectItem(root, "play")->valueint;
		songIDRev = cJSON_GetObjectItem(root, "songID")->valueint;
		volumeRev = cJSON_GetObjectItem(root, "volume")->valueint;
		stopRev = cJSON_GetObjectItem(root, "stop")->valueint;
		// Print Extracted Receive Value
		printf("CURRENT VALUE\n");
		printf("finished: %d\n", DFControl.finished);
		printf("play: %d\n", DFControl.play);
		printf("songID: %d\n", DFControl.songId);
		printf("volume: %d\n", DFControl.volume);
		printf("stop: %d\n", DFControl.stop);

		//
		printf("RECEIVED VALUE\n");
		printf("finished: %d\n", finishedRev);
		printf("play: %d\n", playRev);
		printf("songID: %d\n", songIDRev);
		printf("volume: %d\n", volumeRev);
		printf("stop: %d\n", stopRev);

		// Free the cJSON object
		cJSON_Delete(root);
	}
	else
	{
		ESP_LOGE(TAG, "Error parsing JSON data");
	}
	if (songIDRev != DFControl.songId && songIDRev != 0 && volumeRev != DFControl.volume)
	{
		printf("\nPlay song id and set volume");
		mqtt_data_publish_update("updatePlay");
		DFPLAYER_SetVolume(&MP3, volumeRev * 3);
		DFPLAYER_PlayTrack(&MP3, songIDRev);
		char text[20];
		sprintf(text, "Song %d: Playing", songIDRev);
		ssd1306_clear_line(&dev, 3, false);
		ssd1306_display_text(&dev, 3, text, strlen(text), false);
		char volumeText[10];
		sprintf(volumeText, "Volume: %d", volumeRev);
		ssd1306_clear_line(&dev, 5, false);
		ssd1306_display_text(&dev, 5, volumeText, strlen(volumeText), false);
	}
	else if (songIDRev != DFControl.songId && songIDRev != 0)
	{
		printf("\nplay song id");
		mqtt_data_publish_update("updateSong");
		// mqtt_data_publish_update("updatePlay");
<<<<<<< HEAD
=======
		DFPLAYER_PlayTrack(&MP3, songIDRev);
		char songText[20];
		sprintf(songText, "Song %d: Playing", songIDRev);
		ssd1306_clear_line(&dev, 3, false);
		ssd1306_display_text(&dev, 3, songText, strlen(songText), false);
		char volumeText[10];
		sprintf(volumeText, "Volume: %d", volumeRev);
		ssd1306_clear_line(&dev, 5, false);
		ssd1306_display_text(&dev, 5, volumeText, strlen(volumeText), false);
	}

	else if (volumeRev != DFControl.volume && songIDRev == DFControl.songId)
	{
		printf("\nset volume");
		DFPLAYER_SetVolume(&MP3, volumeRev * 3);
		char volumeText[10];
		sprintf(volumeText, "Volume: %d", volumeRev);
		ssd1306_clear_line(&dev, 5, false);
		ssd1306_display_text(&dev, 5, volumeText, strlen(volumeText), false);
<<<<<<< HEAD
	}
	else if (songIDRev != DFControl.songId && songIDRev != 0)
	{
		printf("\nplay song id");
		mqtt_data_publish_update("updateSong");
		mqtt_data_publish_update("updatePlay");
>>>>>>> main
		DFPLAYER_PlayTrack(&MP3, songIDRev);
		char songText[20];
		sprintf(songText, "Song %d: Playing", songIDRev);
		ssd1306_clear_line(&dev, 3, false);
		ssd1306_display_text(&dev, 3, songText, strlen(songText), false);
	}

	else if (volumeRev != DFControl.volume && songIDRev == DFControl.songId)
	{
		printf("\nset volume");
		DFPLAYER_SetVolume(&MP3, volumeRev * 3);
		char volumeText[10];
		sprintf(volumeText, "Volume: %d", volumeRev);
		ssd1306_clear_line(&dev, 5, false);
		ssd1306_display_text(&dev, 5, volumeText, strlen(volumeText), false);
	}

	if (finishedRev == 1 && songIDRev == DFControl.songId)
	{
		printf("\nLoop");
		mqtt_data_publish_update("updateSong");
		DFPLAYER_PlayTrack(&MP3, songIDRev);
		char songText[20];
		sprintf(songText, "Song %d: Playing", songIDRev);
		ssd1306_clear_line(&dev, 3, false);
		ssd1306_display_text(&dev, 3, songText, strlen(songText), false);
		char volumeText[10];
		sprintf(volumeText, "Volume: %d", volumeRev);
		ssd1306_clear_line(&dev, 5, false);
		ssd1306_display_text(&dev, 5, volumeText, strlen(volumeText), false);
	}

	if (playRev != DFControl.play && playRev == true && songIDRev == DFControl.songId)
	{
		printf("\nResume");
		mqtt_data_publish_update("updatePlay");
		DFPLAYER_Play(&MP3);
		char songText[20];
		sprintf(songText, "Song %d: Playing", songIDRev);
		ssd1306_clear_line(&dev, 3, false);
		ssd1306_display_text(&dev, 3, songText, strlen(songText), false);
	}

	if (playRev != DFControl.play && playRev == false && songIDRev == DFControl.songId)
	{
		printf("\nPause");
		mqtt_data_publish_update("updatePlay");
		DFPLAYER_Pause(&MP3);
		char songText[20];
		sprintf(songText, "Song %d: Pausing", songIDRev);
		ssd1306_clear_line(&dev, 3, false);
		ssd1306_display_text(&dev, 3, songText, strlen(songText), false);
	}
	if (stopRev != DFControl.stop && stopRev == true)
	{
		printf("\n Stop");
		mqtt_data_publish_update("updateStop");
		DFPLAYER_Stop(&MP3);
		ssd1306_clear_line(&dev, 3, false);
		ssd1306_clear_line(&dev, 5, false);
		ssd1306_display_text(&dev, 3, "Turn Off", 8, false);
	}
	DFControl.songId = songIDRev;
	DFControl.volume = volumeRev;
	DFControl.finished = finishedRev;
	DFControl.play = playRev;
	DFControl.stop = stopRev;
	== == == =
}

if (finishedRev == 1 && songIDRev == DFControl.songId)
{
	printf("\nLoop");
	mqtt_data_publish_update("updateSong");
	DFPLAYER_PlayTrack(&MP3, songIDRev);
	char songText[20];
	sprintf(songText, "Song %d: Playing", songIDRev);
	ssd1306_clear_line(&dev, 3, false);
	ssd1306_display_text(&dev, 3, songText, strlen(songText), false);
}

if (playRev != DFControl.play && playRev == true && songIDRev == DFControl.songId)
{
	printf("\nResume");
	mqtt_data_publish_update("updatePlay");
	DFPLAYER_Play(&MP3);
	char songText[20];
	sprintf(songText, "Song %d: Playing", songIDRev);
	ssd1306_clear_line(&dev, 3, false);
	ssd1306_display_text(&dev, 3, songText, strlen(songText), false);
}

if (playRev != DFControl.play && playRev == false && songIDRev == DFControl.songId)
{
	printf("\nPause");
	mqtt_data_publish_update("updatePlay");
	DFPLAYER_Pause(&MP3);
	char songText[20];
	sprintf(songText, "Song %d: Pausing", songIDRev);
	ssd1306_clear_line(&dev, 3, false);
	ssd1306_display_text(&dev, 3, songText, strlen(songText), false);
}
if (stopRev == true && DFControl.stop != stopRev)
{
	printf("\n Stop");
	mqtt_data_publish_update("updateStop");
	DFPLAYER_Stop(&MP3);
	ssd1306_clear_line(&dev, 3, false);
	ssd1306_clear_line(&dev, 5, false);
	ssd1306_display_text(&dev, 3, "Turn Off", 8, false);
}
if (stopRev == false && DFControl.stop != stopRev)
{
	songIDRev = -1;
	volumeRev = -1;
}
DFControl.songId = songIDRev;
DFControl.volume = volumeRev;
DFControl.finished = finishedRev;
DFControl.play = playRev;
DFControl.stop = stopRev;
>>>>>>> refs/remotes/origin/main
}