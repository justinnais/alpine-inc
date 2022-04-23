[Unit]
Description=ToDoApp
Requires=network-online.target
After=network-online.target

[Service]
Environment=DB_URL=mongodb://{{ db_user }}:{{ db_pass }}@{{ db_url }}:27017/
Environment=SESSION_SECRET=secret
WorkingDirectory={{ app_path }}
Type=simple
ExecStart=/usr/bin/node {{ app_path }}server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
