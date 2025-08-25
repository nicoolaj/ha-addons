## RTSP-PROXY
### Configuration

The **RTSP Simple Proxy** add-on allows you to relay your camera's RTSP streams via a lightweight proxy based on **Mediamtx**. To configure it, navigate to the **Configuration** tab of the add-on in Home Assistant.

You must define your list of cameras using a list of name/URL pairs.

**Configuration example:**

```yaml
- name: garden
  url: rtsp://192.168.100.1:554/onvif1
- name: street
  url: rtsp://192.168.100.2/
```

* **`[name]`** : The unique name that will serve as the access path to the camera in the proxy.
* **`[url]`** : The unique name that will serve as the access path to the camera in the proxy.

### Usage

Once the add-on has started, the proxy listens on port **8554** by default (this is configurable via the add-on's Network tab). You can then access each stream using a URL with the following format:

`rtsp://[home_assistant_ip_adress]:[port]/[camera_name]`

* **`[home_assistant_ip_adress]`** : The IP address of your Home Assistant instance (e.g., 192.168.1.100).
* **`[port]`** : The port configured in the add-on for the RTSP proxy (by default, 8554).
* **`[camera_name]`** : The name you defined for the camera in the configuration (garden, street, etc.).

**Concrete example:**

For the camera named garden, the URL for its stream via the proxy would be:

rtsp://192.168.1.100:8554/garden

This URL can be used in software such as Frigate or other Home Assistant integrations to display your camera streams.
