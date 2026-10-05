local cjson = require "cjson"
local server_section = arg[1]
local proto = arg[2]
local local_port = arg[3] or "0"
local socks_port = arg[4] or "0"
local ssrindext = io.popen("dbus get ssconf_basic_json_" .. server_section)
local servertmp = ssrindext:read("*all")
local server = cjson.decode(servertmp)

local transport = server.transport or "tcp"

-- 逗号分隔字符串 -> 数组
local function list_from_str(s)
	local t = {}
	if s then
		for v in string.gmatch(s, "[^,%s]+") do
			table.insert(t, v)
		end
	end
	return t
end

-- 取数值，缺省用 default
local function num(v, default)
	return tonumber(v) or default
end

-- 伪装头类型，缺省 none
local function disguise_header(v)
	return { type = (v and v ~= "") and v or "none" }
end

-- TCP 伪装（none / http）
local function tcp_settings()
	if server.tcp_guise == "http" then
		local paths = list_from_str(server.http_path)
		if #paths == 0 then paths = { "/" } end
		return {
			header = {
				type = "http",
				request = {
					version = "1.1",
					method = "GET",
					path = paths,
					headers = {
						Host = list_from_str(server.http_host),
						["User-Agent"] = {
							"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
							"Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1"
						},
						["Accept-Encoding"] = { "gzip, deflate" },
						Connection = { "keep-alive" },
						Pragma = "no-cache"
					}
				}
			}
		}
	end
	return { header = { type = "none" } }
end

-- KCP
local function kcp_settings()
	return {
		mtu = num(server.mtu, 1350),
		tti = num(server.tti, 50),
		uplinkCapacity = num(server.uplink_capacity, 5),
		downlinkCapacity = num(server.downlink_capacity, 20),
		congestion = (server.congestion == "1") and true or false,
		readBufferSize = num(server.read_buffer_size, 2),
		writeBufferSize = num(server.write_buffer_size, 2),
		header = disguise_header(server.kcp_guise)
	}
end

-- WebSocket
local function ws_settings()
	local path = (server.ws_path and server.ws_path ~= "") and server.ws_path or "/"
	local headers = (server.ws_host and server.ws_host ~= "") and { Host = server.ws_host } or nil
	return { path = path, headers = headers }
end

-- HTTP/2
local function h2_settings()
	return {
		host = list_from_str(server.h2_host),
		path = (server.h2_path and server.h2_path ~= "") and server.h2_path or "/"
	}
end

-- QUIC
local function quic_settings()
	local sec = server.quic_security
	if not sec or sec == "" or sec == "none" then sec = "aes-128-gcm" end
	return {
		security = sec,
		key = server.quic_key or "",
		header = disguise_header(server.quic_guise)
	}
end

-- gRPC
local function grpc_settings()
	return { serviceName = server.grpc_path or "" }
end

-- 传入连接
local inbounds = {}
if local_port ~= "0" then
	table.insert(inbounds, {
		listen = "0.0.0.0",
		port = tonumber(local_port),
		protocol = "dokodemo-door",
		settings = {
			network = proto,
			followRedirect = true
		},
		sniffing = {
			enabled = true,
			destOverride = { "http", "tls" }
		}
	})
end
if proto == "tcp" and socks_port ~= "0" then
	table.insert(inbounds, {
		listen = "0.0.0.0",
		port = tonumber(socks_port),
		protocol = "socks",
		settings = {
			auth = "noauth",
			udp = true
		}
	})
end

-- 底层传输配置
local stream = {
	network = transport,
	security = (server.tls == "1") and "tls" or "none",
	tlsSettings = (server.tls == "1") and {
		allowInsecure = (server.insecure ~= "0") and true or false,
		serverName = server.tls_host
	} or nil,
	tcpSettings = (transport == "tcp") and tcp_settings() or nil,
	kcpSettings = (transport == "kcp") and kcp_settings() or nil,
	wsSettings = (transport == "ws") and ws_settings() or nil,
	grpcSettings = (transport == "grpc") and grpc_settings() or nil,
	httpSettings = (transport == "h2") and h2_settings() or nil,
	quicSettings = (transport == "quic") and quic_settings() or nil
}

local v2ray = {
	log = {
		loglevel = "warning"
	},
	-- 传入连接
	inbounds = inbounds,
	-- 传出连接
	outbounds = {
		{
			tag = "proxy",
			protocol = "vmess",
			settings = {
				vnext = {
					{
						address = server.server,
						port = tonumber(server.server_port),
						users = {
							{
								id = server.vmess_id,
								alterId = tonumber(server.alter_id) or 0,
								security = (server.security and server.security ~= "") and server.security or "auto"
							}
						}
					}
				}
			},
			streamSettings = stream,
			mux = {
				enabled = (server.mux == "1") and true or false,
				concurrency = tonumber(server.concurrency)
			}
		},
		-- 额外传出连接
		{
			tag = "direct",
			protocol = "freedom",
			settings = { keep = "" }
		}
	}
}

print(cjson.encode(v2ray))
