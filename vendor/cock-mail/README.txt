Cock-mail — yeah it's webmail with cocks
<https://mail.cock.li/cock-mail/>
Version: 0.5.1 (beta)

> ABOUT

    Cock-mail is the world's first fully client-side webmail client. It's what
    webmail should have been. Cock-mail connects directly to IMAP and SMTP
    over WebSockets and manages the entire session in your browser from start
    to finish.  This approach eliminates a broad stroke of security risks you
    take every time you use a server-side webmail application. Instead of
    relying on a crusty PHP or C backend to log in for you and manage client
    state, cock-mail speaks mail protocols natively and skips the middleman.

    Another problem with webmail is the issue of how to convert an HTML e-mail
    into something that can be safely displayed in browsers. This is a *hard*
    problem and has been the source of innumerable XSS vulnerabilities in
    existing webmail applications. Cock-mail addresses this by *refusing* to
    convert HTML to anything other than plaintext. More specifically its HTML
    converter uses DOMParser to parse HTML message parts, extract links, and
    convert the untrusted code to plaintext with innerText. This way the
    features of modern browsers designed to handle untrusted input are used
    for their intended purpose.

    Cock-mail's developers strongly believe the best e-mail client is a
    desktop client and aim to replicate one.

> DONATE

    Please support the development of cock-mail by making a donation with
    cryptocurrency: <https://cock.li/donate.php>

> INSTALL

    0. Prerequisites

    You will need a working IMAP and SMTP server. This document assumes you
    use Dovecot for IMAP and Postfix for SMTP, but you should be able to use
    any mail software.

    This software package builds Docker base images from scratch and uses
    docker-compose to easily build and deploy services. Cock-mail will work
    easily with other container software or none at all, but Docker is the
    official way to deploy cock-mail.

    0.1. Required service capabilities

    All of these are default in modern dovecot and postfix.

        IMAP: QRESYNC, UIDPLUS
        SMTP: AUTH PLAIN

    0.2. Required versions (for haproxy support)

        dovecot: >= 2.2.19 (2015)
        postfix: >= 3.5    (2020)

    0.3. Build dependencies

        1. docker compose
        2. coreutils (sha256sum)
        3. curl
        4. gnupg2

    1. Information about Websockify patches

    Cock-mail patches Websockify to support two new options:

        1. --haproxy=2
            (send PROXYv2 headers to target)
        2. --ssl-target-name=mail.example.com
            (expect SSL to verify as mail.example.com instead of target
            hostname)

    2. Configure your mail services

    Cock-mail can connect to any modern mail server without requiring special
    configuration. If you are connecting with SSL, you will need access to the
    TLS-wrapped ports 993(imaps) and 465(smtps). STARTTLS (which delays TLS
    until it receives a command from the client) is not supported on
    cock-mail.

    If you're connecting to your own mail server and want to pass along
    browser IPs, you will need to configure your IMAP and SMTP daemons to
    listen on new ports with haproxy enabled, and whitelist the IP cock-mail
    connects from to allow it to pass along client IPs.

    For dovecot, a.b.c.d/32 should be the IP address cock-mail connects from.
    For postfix, you MUST prevent random IPs from connecting to the ports you
    open, for example by restricting your firewall to only allow connections
    to those ports from a.b.c.d/32. You may as well firewall dovecot proxy
    ports as well.

    You will need to reload or restart your mail services to apply these
    changes.

    2.1. Configure Dovecot

    In /etc/dovecot/conf.d/10-master.conf:

        ...
    +   haproxy_trusted_networks = a.b.c.d/32
        service imap-login {
    +       inet_listener imap-haproxy {
    +           port = 10143
    +           haproxy = yes
    +       }
    +       inet_listener imaps-haproxy {
    +           port = 10993
    +           ssl = yes
    +           haproxy = yes
    +       }
            ...

    2.2. Configure Postfix

    In /etc/postfix/master.cf:

    +   10025    inet    n   -   y   -   -   smtpd
    +       -o smtpd_upstream_proxy_protocol=haproxy
    +       -o smtpd_tls_security_level = may
    +   10465    inet    n   -   y   -   -   smtpd
    +       -o smtpd_upstream_proxy_protocol=haproxy
    +       -o smtpd_tls_wrappermode=yes

    Note: "y" here enables chroot (postfix default). If your postfix doesn't
    use chroot, you will need to change these to "n".

    3. Build base image

    Run `build-base.sh` which does the following:
    
        1. Downloads the latest Alpine Linux mini rootfs and extracts it to
           docker/alpine/alpine
        2. Builds Alpine docker image and tags it as local.local/alpine:mini

    4. Configure docker-compose

    Edit docker-compose.yml to your requirements or create
    docker-compose.override.yml. You may need to change the following:

        1. By default nginx opens port 8143 and 8142. 8143 is used for reverse
           HTTP proxies (like haproxy or another nginx) and assumes this
           reverse proxy sets X-Forwarded-For. 8142 is used to allow use
           through a Tor hidden service (it sets X-Forwarded-For to
           127.0.0.1). If you want direct access e.g. for testing during
           setup, use 8142.
        2. You will need to uncomment the relevant `command:` line in the
           websockify services and change "dovecot:10143" and "postfix:10025"
           to point to your mail services.

    5. Build and Deploy

    ` docker-compose build ` and then ` docker compose up -d `. Now you can
    visit <http://docker_ip:8142> to test.

    6. Secure

    You MUST secure port 8143 and 8142 to only allow connections from your
    upstream HTTP server and Tor (if used) respectively. Failure to do this
    will allow clients to specify their own X-Forwarded-For header, enabling
    spoofed client IP addresses in your mail server logs. If these connecting
    services are on the same server you can adjust the nginx ports in
    docker-compose.yml to only listen on localhost:

        ...
        nginx:
            ports:
                - "127.0.0.1:8143:80"
                - "127.0.0.1:8142:81"

    Remember to run ` docker compose up -d ` afterwards.

> CONTACT

    If you find any bugs or would like to submit a patch, send your RFC822-
    compliant internet message to <official-dev.cock-mail-dev // cock.li>.
