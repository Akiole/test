var ipmonitor_last = [<% get_static_client(); %>];
var nmap_fullscan_last = '<% nvram_get_x("", "networkmap_fullscan"); %>';
var ipv6_neigh_map = [<% ipv6_neigh_list(); %>];
var wireless_band_last = {<% wl_band_list(); %>};
