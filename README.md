# Universal HTTP Sender - Control4 Driver
**System requirements:**

1.     OS 2.10.5+

The Universal HTTP sender is an extension of theDriverWorks generic\_http driver. It is designed to send GET, POST, PUT or DELETE commands to one of five pre-defined URLs (set in Properties) or a manually defined URL (set in the Command parameters). Variable and events are provided for basic handling of any response. These commands are available for use in the programming section of Composer by selecting “Universal HTTP Sender” in the Actions menu.

## Properties

#### Debug Mode:

When set to On, prints out on the Lua tab the URL being requested and the response from the remote server (or in case of an error, the error message)

#### URL Timeout:

The time (in seconds) that the URL engine will wait for a response before timing out and returning an error.

#### Preset URL \[1-5\]

Enter a URL here (including the leading http:// or https://) for later access in programming

## Commands

#### GET Preset: \[PRESET, JSON\_HEADER\]

Send a HTTP GET command to the URL predefined on the Properties page in Preset \[PRESET\] with an optional header \[JSON\_HEADER\]

#### GET Manual: \[URL, JSON\_HEADER\]

Send a HTTP GET command to the URL specified in \[URL\] with an optional header \[JSON\_HEADER\]

#### POST Preset: \[PRESET, DATA, JSON\_HEADER\]

Send a HTTP POST command to the URL predefined on the Properties page in Preset \[PRESET\] with attached data as specified in \[DATA\] and an optional header \[JSON\_HEADER\]

#### POST Manual: \[URL, DATA, JSON\_HEADER\]

Send a HTTP POST command to the URL specified in \[URL\] with attached data as specified in \[DATA\] and an optional header \[JSON\_HEADER\]

#### PUT Preset: \[PRESET, DATA, JSON\_HEADER\]

Send a HTTP PUT command to the URL predefined on the Properties page in Preset \[PRESET\] with attached data as specified in \[DATA\]and an optional header \[JSON\_HEADER\]

#### PUT Manual: \[URL, DATA, JSON\_HEADER\]

Send a HTTP PUT command to the URL specified in \[URL\] with attached data as specified in \[DATA\] and an optional header \[JSON\_HEADER\]

#### DELETE Preset: \[PRESET, JSON\_HEADER\]

Send a HTTP DELETE command to the URL predefined on the Properties page in Preset \[PRESET\] with an optional header \[JSON\_HEADER\]

#### DELETE Manual: \[URL, JSON\_HEADER\]

Send a HTTP DELETE command to the URL specified in \[URL\] with an optional header \[JSON\_HEADER\]

## Variables

#### HTTP\_ERROR(string)

The error string returned from the URL engine, or an empty string if there was no error.

#### HTTP\_RESPONSE\_CODE(number)

The HTTP response code returned from the HTTP server, or 0 if there was an error.

#### HTTP\_RESPONSE\_DATA(string)

The data returned from the HTTP server, or an empty string if there was an error.

## Events

#### Success

Fires when the HTTP command was successfully sent to the server and an HTTP response code was returned. The HTTP\_RESPONSE\_DATA and HTTP\_RESPONSE\_CODE variables will be populated with the data from the URL call.

Note that an HTTP 400 or 500 response will still result in the Success event but indicates either a client or server error.

#### Error

Fires when the URL engine returns an error.  The HTTP\_ERROR variable will be populated with the error code from the URL engine.

## Example Use Cases

#### Webhooks

Use this driver to send a HTTP command to a webhook created with an external device/service. Enter the webhook URL into the URLfield and run a GET command.

#### Home Assistant

Send API calls to Home Assistant to control devices that are not compatible with Control4 or require a driver that you do not have.

See [https://developers.home-assistant.io/docs/api/rest/](https://developers.home-assistant.io/docs/api/rest/) for all REST API commands you can send from this driver to Home Assistant.

_E.g. Running a Home Assistant Script from Control4:_

1.      From the Home Assistant Sidebar go to Profile > Security and scroll to ‘Long-lived access tokens.’

2.      Select ‘Create Token’, set a name, and copy the generated token.

3.      In Composer use one of the POST commands via an action in the programming section or by the driver’s action tab in system design (for testing).

4.      Paste your token into the JSON\_HEADER field using the format below and replace 'TOKEN\_HERE' with your Home Assistant Access Token:

{ “Authorization": "Bearer TOKEN\_HERE" }

5.      In the URL field enter your home assistant URL and PORT followed by the script path like the example below:

http://192.168.x.x:8123/api/services/script/my-script

6.      If your script requires fields, add these to the DATA field in JSON format like the example below:

{ "entity\_id":"media\_player.my\_media\_player" }

7.      Execute the script to send the HTTP Command to Home Assistant.

8.      Turn on debugging in the driver’s properties to print output/error messages to the Lua tab.
