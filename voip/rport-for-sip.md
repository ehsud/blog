rport，received 用于解决 NAT 网络问题，假设 freeswitch 在公网上， 话机客户端在内网，并且话机支持 rport 功能，网络结构如下图



 Freeswitch     -----         Firewall        -------      eyeBeam

112.2.80.88              110.202.56.98             192.168.1.120



客户端 eyeBeam 需要向外网的 freeswitch 注册自己的账号，比如 1000 这个账号，它的 AOR 地址就是 1000@112.2.80.88，首先 eyeBeam 需要发一个注册请求到 freeswitch 如下



```
IP 110.202.56.98:54526 > 112.2.80.88:5060

REGISTER sip:112.2.80.88 SIP/2.0
Via: SIP/2.0/UDP 192.168.1.120:61724;branch=z9hG4bKd87543b546ef427e40652ed87543;rport
Max-Forwards: 70
Contact: <sip:1000@192.168.1.120:61724;rinstance=720a51c7a6494ef5>
To: "1002"<sip:1000@112.2.80.88>
From: "1002"<sip:1000@112.2.80.88>;tag=ac467c15
Call-ID: M2M1MDFhOWVkYThhYzg0ZDg0ZWE4N2JiYWRhZjc0YmY.
CSeq: 1 REGISTER
Expires: 3600
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, NOTIFY, MESSAGE, SUBSCRIBE, INFO
User-Agent: eyeBeam release 1011d stamp 40820
Content-Length: 0
```



从上面可以看到，客户端 eyeBeam 向外网 freeswitch 发送的注册请求，其中在 `via` 字段中添加了一个 rport 为空的参数，表示这个 eyeBeam 客户端支持 rport 功能。经过 Firewall 防火墙之后，防火墙使用 NAT 将这个注册请求的源 IP 地址映射成了公网 110.202.56.98 端口 54526 再转发给外网的 freeswitch，而在这个注册请求中，eyebeam 客户端并不知道自己经过防火墙之后的公网 IP 和端口，所以在 sip 消息中只能将 `Contact` 字段值设置为 192.168.1.120。之后在 freeswitch 端接收到这个请求后，freeswitch 看到的实际请求源 IP 地址为 110.202.56.98 端口为 54526，而在 SIP 消息中 `Contact` 字段值为 192.168.1.120 为一个 RFC1918 规定中的内网 IP 地址，这个时候 freeswitch 就知道，这个 eyeBeam 客户端是在一个 NAT 设备后的内网中，所以在接下来给 eyeBeam 客户端发送的 `401 Unauthorized` 响应消息中，freeswitch 会在消息 `Via` 字段中修改 rport 为 54526，并添加 received 字段，其值为 110.202.56.98，rport 和  received 表示告诉这个内网 eyeBeam 客户，它的公网端口是 54526，公网 IP 地址为 110.202.56.98



```
IP 112.2.80.88:5060 > 110.202.56.98:54526

SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 192.168.1.120:61724;branch=z9hG4bKd87543b546ef427e40652ed87543;rport=54526;received=110.202.56.98
To: "1000"<sip:1000@112.2.80.88>;tag=9dd61ff61e802d8e2bef5f14621ef3c2.7e573673
From: "1000"<sip:1000@112.2.80.88>;tag=ac467c15
Call-ID: M2M1MDFhOWVkYThhYzg0ZDg0ZWE4N2JiYWRhZjc0YmY.
CSeq: 1 REGISTER
WWW-Authenticate: Digest realm="112.2.80.88", nonce="XsuavF7LmZC5v1tmAaOfJQ5V/tROTtfF"
Content-Length: 0
```



接下来 eyeBeam 客户端收到 freeswitch 发来的 401 Unauthorized 响应消息时，客户端 eyeBeam 就能从响应消息中 Via 字段的 rport 和 received 参数知道自己经过 Firewall 防火墙后的公网 IP 地址和端口号，于是 eyebeam 就会重新发起一个携带认证信息的注册请求到外网的 freeswitch，并且将原来的 `Contact` 字段值修改为 received 和 rport 所指定的公网 IP 110.202.56.98 和端口 54526

```
IP 110.202.56.98:54526 > 112.2.80.88:5060

REGISTER sip:112.2.80.88 SIP/2.0
Via: SIP/2.0/UDP 192.168.1.120:61724;branch=z9hG4bKd875438a7796300266c44ed87543;rport
Max-Forwards: 70
Contact: <sip:1000@110.202.56.98:54526;rinstance=99557183e8f3d8db>
To: "1002"<sip:1000@112.2.80.88>
From: "1002"<sip:1000@112.2.80.88>;tag=ac467c15
Call-ID: M2M1MDFhOWVkYThhYzg0ZDg0ZWE4N2JiYWRhZjc0YmY.
CSeq: 4 REGISTER
Expires: 3600
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, NOTIFY, MESSAGE, SUBSCRIBE, INFO
User-Agent: eyeBeam release 1011d stamp 40820
Authorization: Digest username="1000",realm="112.2.80.88",nonce="XsuavF7LmZC5v1tmAaOfJQ5V/tROTtfF",uri="sip:112.2.80.88",response="8d6cc5e5a87269bfc9515371502ec838",algorithm=MD5
Content-Length: 0
```



接下来 freeswitch 就能正确的识别和绑定 eyeBeam 客户端的 Contact 联系地址，在之后的所有请求就都使用 Contact 中指定的 IP 和端口来向 eyebeam 客户端发送消息