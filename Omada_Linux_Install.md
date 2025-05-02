Omada was a pain to install. This is what I did to get it working.

---

## Omada Install

Refer to [this guide](https://www.tp-link.com/us/support/faq/3272/).
Use for Omada v5.15.20.20 +

---

### Repos and Software

This section gets the repositories and software required:

    sudo apt update && install -y gnupg curl openjdk-17-jre-headless
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt update
    apt install mongodb-org

---

### Omada Install

To install the Omada software ([download here](https://www.tp-link.com/us/support/download/omada-software-controller/#Controller_Software)):

    cd /opt/
    wget https://static.tp-link.com/upload/software/2022/202205/20220507/Omada_SDN_Controller_v5.3.1_Linux_x64.tar.gz
    tar -zxvf Omada_SDN_Controller_v5.3.1_Linux_x64.tar.gz
    cd Omada_SDN_Controller_v5.3.1_Linux_x64
    sudo ./install.sh
    sudo rm -rf Omada_SDN_Controller_v5.3.1_Linux_x64.tar.gz
