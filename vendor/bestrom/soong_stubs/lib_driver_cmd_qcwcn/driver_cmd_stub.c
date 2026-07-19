#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

/* Private driver cmd used by nl80211 path */
int wpa_driver_nl80211_driver_cmd(void *priv, char *cmd, char *buf, size_t buf_len)
{
	(void)priv;
	if (buf && buf_len)
		buf[0] = '\0';
	if (cmd && buf && buf_len && strncmp(cmd, "GET_", 4) == 0)
		snprintf(buf, buf_len, "OK");
	return 0;
}

/* P2P / AP helpers referenced by driver_nl80211_proxy when qcwcn is selected */
int wpa_driver_set_ap_wps_p2p_ie(void *priv, const void *beacon,
				const void *proberesp, const void *assocresp)
{
	(void)priv;
	(void)beacon;
	(void)proberesp;
	(void)assocresp;
	return 0;
}

int wpa_driver_get_p2p_noa(void *priv, uint8_t *buf, size_t len)
{
	(void)priv;
	if (buf && len)
		memset(buf, 0, len);
	return 0;
}

int wpa_driver_set_p2p_noa(void *priv, uint8_t count, int start, int duration)
{
	(void)priv;
	(void)count;
	(void)start;
	(void)duration;
	return 0;
}

int wpa_driver_set_p2p_ps(void *priv, int legacy_ps, int opp_ps, int ctwindow)
{
	(void)priv;
	(void)legacy_ps;
	(void)opp_ps;
	(void)ctwindow;
	return 0;
}

int wpa_driver_set_tdls_mode(void *priv, int tdls_external_control)
{
	(void)priv;
	(void)tdls_external_control;
	return 0;
}

int wpa_driver_signal_monitor(void *priv, int threshold, int hysteresis)
{
	(void)priv;
	(void)threshold;
	(void)hysteresis;
	return 0;
}

int wpa_driver_get_rx_filters(void *priv, char *buf, size_t buf_len)
{
	(void)priv;
	if (buf && buf_len)
		buf[0] = '\0';
	return 0;
}

int wpa_driver_set_rx_filter_enable(void *priv, int enable)
{
	(void)priv;
	(void)enable;
	return 0;
}

int wpa_driver_set_rx_filter_add(void *priv, int filter_num, char *params)
{
	(void)priv;
	(void)filter_num;
	(void)params;
	return 0;
}

int wpa_driver_set_rx_filter_remove(void *priv, int filter_num)
{
	(void)priv;
	(void)filter_num;
	return 0;
}

/* Some trees export these as well */
int wpa_driver_nl80211_driver_event(void *priv, uint32_t vendor_id,
				    uint32_t subcmd, uint8_t *data, size_t len)
{
	(void)priv;
	(void)vendor_id;
	(void)subcmd;
	(void)data;
	(void)len;
	return 0;
}
