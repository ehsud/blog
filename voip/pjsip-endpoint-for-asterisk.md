在 Asterisk 中，PJSIP 协议栈当中的配置对象最重要的就是 Endpoint 节点配置，在 Endpoint 节点中有相当多的配置参数



### Endpoint 参数详解

* **100rel**     -- Allow support for RFC3262 provisional ACK tags

在 SIP 协议中规定了请求方法，和响应方法。而响应又分临时响应和最终响应，其中最终响应需要使用 ACK 进行确认，保证最终响应数据包的可靠传输。而在 SIP RFC3261 标准中临时响应不需要 ACK 确认，也就是临时响应有时候可能会出现丢包现象，然后在 RFC3262 标准中加入了 PRACK 方法，用来对临时响应的确认。这种对临时响应进行确认机制被称为 100rel

* **aggregate_mwi**   -- Condense MWI notifications into a single NOTIFY.

将 MWI 通知封装到一个 NOTIFY 消息中



* **allow**     -- Media Codec(s) to allow

Endpoint 允许的语音编码，在编码协商中会使用此编码列表进行匹配



* **allow_overlap**    -- Enable RFC3578 overlap dialing support.

是否允许 RFC3578 标准中的重叠拨号特性

* **aors**     -- AoR(s) to be used with the endpoint

为 Endpoint 指定 AOR 配置信息，通常指向一个 type 为 aor 的配置节点

* **auth**      -- Authentication Object(s) associated with the endpoint

为 Endpoint 指定身份认证方式，比如认证用户和密码，通常指定一个 type 为

* **callerid**       -- CallerID information for the endpoint

为 Endpoint 指定 callerid 主叫号码

* **callerid_privacy**      -- Default privacy level

是否使用 callerid 主叫信息隐藏功能，一般有三种级别，screen 全部隐藏，name 隐藏主叫名称，number 隐藏主叫号码

* **callerid_tag**    -- Internal id_tag for the endpoint

设置 Endpoint 在 Asterisk 内部的 ID 标签

* **context**      -- Dialplan context for inbound sessions

设置 Endpoint 的默认 Context 路由，也就是在 extensions.conf 文件中定义的拨号方案

* **direct_media_glare_mitigation** -- Mitigation of direct media (re)INVITE glare
* **direct_media_method**       -- Direct Media method type
* **trust_connected_line**      -- Accept Connected Line updates from this endpoint
* **send_connected_line**       -- Send Connected Line updates to this endpoint
* **connected_line_method**     -- Connected line method type
* **direct_media**     -- Determines whether media may flow directly between endpoints.

是否允许通话双方之间直接传输媒体，而不需要经过 Asterisk。通常在 NAT 环境中可能会出现通话没有声音的问题，一般需要设置为 `no`，让 Asterisk 来控制 RTP 媒体传输

* **disable_direct_media_on_nat** -- Disable direct media session refreshes when NAT obstructs the med

当在 NAT 环境中时，是否在直接媒体传输通话的会话中禁止媒体会话刷新

* **disallow**     -- Media Codec(s) to disallow

  为 Endpoint 媒体编码设置不允许使用的编码列表，`all` 表示禁止所有

* **dtmf_mode**     -- DTMF mode

为 Endpoint 设置 DTMF 模式，一般有以下几种可选

| type      | description                                                  |
| --------- | ------------------------------------------------------------ |
| rfc4733   | 使用与 chan_sip 中所使用的 rfc2833 相同的方式                |
| inband    | 这种方式表示将 DTMF 作为音频流的一部分进行传输发送           |
| info      | 使用 SIP 协议中的 INFO 方法传输 DTMF 信号                    |
| auto      | 自动模式，默认使用 RFC4733 方式，如果对方不支持则使用 inband 方式 |
| auto_info | 自动模式，默认使用 RFC4733 方式，如果对方不支持则使用 info 方式 |

* **media_address**    -- IP address used in SDP for media handling

设置 Asterisk 媒体协商 SDP 中的媒体地址

* **bind_rtp_to_media_address**      -- Bind the RTP instance to the media_address

将 RTP 实例绑定到 media_address 参数指定的媒体地址上

* **force_rport**    -- Force use of return port

强制 Endpoint 使用 rport，rport 通常用来在 NAT 环境中进行内网穿透处理

* **ice_support**     -- Enable the ICE mechanism to help traverse NAT

为 Endpoint 启用 ICE 支持，ICE 通常也是用于 NAT 环境中的传输处理

* **identify_by**      -- Way(s) for the endpoint to be identified

指定对呼入的流量使用什么方式进行认证，同时如果有注册则表示如何确定 AOR 地址的方式，此参数必须指定至少一种方式，多个方式使用逗号分隔

| type          | description                                        |
| ------------- | -------------------------------------------------- |
| username      |                                                    |
| auth_username |                                                    |
| ip            | 根据请求的源 IP 地址来匹配 Endpoint 并进行身份识别 |
| header        |                                                    |



* redirect_method    -- How redirects received from an endpoint are handled
* mailboxes     -- NOTIFY the endpoint when state changes for any of the specified m
* mwi_subscribe_replaces_unsolicited -- An MWI subscribe will replace sending unsolicited NOTIFYs
* voicemail_extension    -- The voicemail extension to send in the NOTIFY Message-Account hea
* moh_suggest     -- Default Music On Hold class
* **outbound_auth**      -- Authentication object(s) used for outbound requests

在向外部网关注册时，指定验证方式。通常指向一个 type 为 auth 的配置节点

* outbound_proxy     -- Full SIP URI of the outbound proxy used to send requests
* **rewrite_contact**     -- Allow Contact header to be rewritten with the source IP address-p

是否允许使用消息的源 IP 地址改写 SIP 协议中的 contact 头字段

* **rtp_ipv6**      -- Allow use of IPv6 for RTP traffic

是否允许 RTP 使用 IPV6 地址

* **rtp_symmetric**    -- Enforce that RTP must be symmetric

强制通话双方的 RTP 使用同样的端口号

* send_diversion    -- Send the Diversion header, conveying the diversion information to
* **send_pai**     -- Send the P-Asserted-Identity header

在请求头中使用 P-Asserted-Identity 字段头域作为主叫号码识别

* **send_rpid**     -- Send the Remote-Party-ID header

在请求头中使用 Remote-Party-ID 字段头域作为主叫号码识别

* rpid_immediate   -- Immediately send connected line updates on unanswered incoming ca
* timers_min_se    -- Minimum session timers expiration period
* timers     -- Session timers for SIP packets
* timers_sess_expires    -- Maximum session timer expiration period
* **transport**    -- Explicit transport configuration to use

为 Endpoint 绑定一个传输方式，也就是 IP 和 传输协议。通常指定 type 为 transport  的传输配置节点

* trust_id_inbound     -- Accept identification information received from this endpoint
* trust_id_outbound     -- Send private identification details to the endpoint.
* type      -- Must be of type 'endpoint'.

默认必须设置 Endpoint 配置节点的 type 类型为 endpoint，表示这是一个 endpoint 配置节点

* use_ptime      -- Use Endpoint's requested packetization interval
* use_avpf      -- Determines whether res_pjsip will use and enforce usage of AVPF f
* force_avp     -- Determines whether res_pjsip will use and enforce usage of AVP, r
* media_use_received_transport     -- Determines whether res_pjsip will use the media transport receive
* media_encryption    -- Determines whether res_pjsip will use and enforce usage of media
* media_encryption_optimistic    -- Determines whether encryption should be used if possible but does
* g726_non_standard     -- Force g.726 to use AAL2 packing order when negotiating g.726 audi
* inband_progress      -- Determines whether chan_pjsip will indicate ringing using inband
* call_group       -- The numeric pickup groups for a channel.

为 Endpoint 设置 call_group 呼叫组

* **pickup_group**      -- The numeric pickup groups that a channel can pickup.

为 Endpoint 设置 pickup_group 截答组

* named_call_group     -- The named pickup groups for a channel.
* named_pickup_group     -- The named pickup groups that a channel can pickup.
* device_state_busy_at     -- The number of in-use channels which will cause busy to be returne
* t38_udptl        -- Whether T.38 UDPTL support is enabled or not
* t38_udptl_ec      -- T.38 UDPTL error correction method
* t38_udptl_maxdatagram     -- T.38 UDPTL maximum datagram size
* fax_detect       -- Whether CNG tone detection is enabled
* fax_detect_timeout      -- How long into a call before fax_detect is disabled for the call
* t38_udptl_nat      -- Whether NAT support is enabled on UDPTL sessions
* t38_udptl_ipv6      -- Whether IPv6 is used for UDPTL Sessions
* tone_zone      -- Set which country's indications to use for channels created for t
* language       -- Set the default language to use for channels created for this end

为 Endpoint 设置用户用户语言

* one_touch_recording      -- Determines whether one-touch recording is allowed for this endpoi
* **record_on_feature**      -- The feature to enact when one-touch recording is turned on.

当用户一键式录音开启时所要执行的动作

* record_off_feature     -- The feature to enact when one-touch recording is turned off.
* rtp_engine       -- Name of the RTP engine to use for channels created for this endpo
* allow_transfer      -- Determines whether SIP REFER transfers are allowed for this endpo
* user_eq_phone       -- Determines whether a user=phone parameter is placed into the requ
* moh_passthrough     -- Determines whether hold and unhold will be passed through using r
* sdp_owner        -- String placed as the username portion of an SDP origin (o=) line.
* sdp_session       -- String used for the SDP session (s=) line.
* tos_audio       -- DSCP TOS bits for audio streams
* tos_video       -- DSCP TOS bits for video streams
* cos_audio        -- Priority for audio streams
* cos_video        -- Priority for video streams
* allow_subscribe       -- Determines if endpoint is allowed to initiate subscriptions with

是否开启 Endpoint 用户订阅通知

* sub_min_expiry      -- The minimum allowed expiry time for subscriptions initiated by th
* from_user       -- Username to use in From header for requests to this endpoint.

设置请求头中的 From 字段用做 Username 用户名

* mwi_from_user      -- Username to use in From header for unsolicited MWI NOTIFYs to thi
* from_domain       -- Domain to user in From header for requests to this endpoint.

设置请求头中的 From 字段用作 Domain 域

* dtls_verify     -- Verify that the provided peer certificate is valid
* dtls_rekey     -- Interval at which to renegotiate the TLS session and rekey the SR
* dtls_auto_generate_cert   -- Whether or not to automatically generate an ephemeral X.509 certi
* dtls_cert_file     -- Path to certificate file to present to peer
* dtls_private_key    -- Path to private key for certificate file
* dtls_cipher       -- Cipher to use for DTLS negotiation
* dtls_ca_file     -- Path to certificate authority certificate
* dtls_ca_path     -- Path to a directory containing certificate authority certificates
* dtls_setup     -- Whether we are willing to accept connections, connect to the othe
* dtls_fingerprint    -- Type of hash to use for the DTLS fingerprint in the SDP.
* srtp_tag_32    -- Determines whether 32 byte tags should be used instead of 80 byte
* set_var     -- Variable set on a channel involving the endpoint.

当 Endpoint 发起呼叫请求时，在通道上设置一些通道变量

* message_context    -- Context to route incoming MESSAGE requests to.
* accountcode   -- An accountcode to set automatically on any channels created for this endpoint. 
* preferred_codec_only      -- Respond to a SIP invite with the single most preferred codec rath
* rtp_keepalive             -- Number of seconds between RTP comfort noise keepalive packets.
* rtp_timeout               -- Maximum number of seconds without receiving RTP (while off hold)
* rtp_timeout_hold          -- Maximum number of seconds without receiving RTP (while on hold) b
* acl                       -- List of IP ACL section names in acl.conf
* deny                      -- List of IP addresses to deny access from
* permit                    -- List of IP addresses to permit access from
* contact_acl               -- List of Contact ACL section names in acl.conf
* contact_deny              -- List of Contact header addresses to deny
* contact_permit            -- List of Contact header addresses to permit
* subscribe_context         -- Context for incoming MESSAGE requests.
* contact_user              -- Force the user on the outgoing Contact header to this value.
* asymmetric_rtp_codec      -- Allow the sending and receiving RTP codec to differ
* rtcp_mux                  -- Enable RFC 5761 RTCP multiplexing on the RTP port
* refer_blind_progress      -- Whether to notifies all the progress details on blind transfer
* notify_early_inuse_ringing -- Whether to notifies dialog-info 'early' on InUse&Ringing state
* max_audio_streams         -- The maximum number of allowed audio streams for the endpoint
* max_video_streams         -- The maximum number of allowed video streams for the endpoint
* bundle                    -- Enable RTP bundling
* webrtc                    -- Defaults and enables some options that are relevant to WebRTC
* incoming_mwi_mailbox      -- Mailbox name to use when incoming MWI NOTIFYs are received
* follow_early_media_fork   -- Follow SDP forked media when To tag is different
* accept_multiple_sdp_answers -- Accept multiple SDP answers on non-100rel responses
* suppress_q850_reason_headers -- Suppress Q.850 Reason headers for this endpoint
* ignore_183_without_sdp    -- Do not forward 183 when it doesn't contain SDP