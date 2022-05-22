[Unit]
Description=notes
Requires=network-online.target
After=network-online.target

[Service]
Environment=SERVER=mongodb://{{ db_url }}:27017/notes
WorkingDirectory={{ app_path }}
Type=simple
ExecStart=/usr/bin/node {{ app_path }}/app.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
