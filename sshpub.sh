#!/bin/bash

mkdir -p ~/.ssh

EXISTS=$(grep generated-by-azure ~/.ssh/authorized_keys | wc -l)

if [[ $EXISTS = 0 ]]; then
tee -a ~/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCeB3WHNRdq3KRTjX88pQ1ieMQbf5SC+77K+ZAWQYja9sThojm11s1PZEU1QGvT2MGpochKSRvOiR7gRlsCBLCeuayOCJYo00FOYY1NmNYmz5JTxyyHQSATNDTEvw7MLImRBVS0qnKmtqfhTfBFVtSneqgusPrxLgYVpcVoFj9ezG+ml1st/yY+rfS/AvaxD1tmuE1E4mVTe7qcPQRzEmWuI7OJ4SCOOltwKgP8xanZp0Dd8vLXCPSXGCxJxdgg6zgY0Irc0GLoN6gKg/3l+wfsr+gP8FOrBSTHjkUC24VUk5+SUC7BjuUzfTjm5+oL4JgUQR5mCm9sqKNcxeuvhmUmH2ZHrRHxp2+uWD1wfUEsH/H1t1mVHYk5crgEKYqJ1U5v3b/aQOffNXK61ylDdfbkLu/pRK+SmknUbYrdQl0phoQpQwo7t4FuD6bJCtHL7DYJPQoaOv8Pmq5TP3vh++CDaGCIFcGtvXz66vdshH2Ew/z9mA7XzyBr+/95t3S1ozM= generated-by-azure
EOF
chmod 600 ~/.ssh/authorized_keys
fi

sed -i.bak "s/#PubkeyAuthentication .*$/PubkeyAuthentication yes/" /etc/ssh/sshd_config

systemctl restart ssh
