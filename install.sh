#!/bin/bash
################################################################################
#      Script para instalacao do Lookinglgass baseado no Hyperglass            #
# Utilizacao> Execute o arquivo como root e escolha as opcoes                  #
#                                                                              #
#                                                                              #
#                                                                              #
#Autor: Ricardo Jr                                                             #
#Data: 15/04/2025                                                               #
################################################################################
file_hyperglass="/root/LookingGlass_Custom/"

set -e


if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root."
   exit 1
fi

check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "❌ Dependencia ausente: '$1'. Por favor, instale com:"
        case "$1" in
            wget)
                apt install wget -y
                ;;
            ipcalc)
                apt install ipcalc -y
                ;;
            dialog)
                apt install dialog -y
                ;;
        esac
    fi
}

echo "Verificando dependencias..."
check_command wget
check_command ipcalc
check_command dialog
echo "✅ Todas as dependencias estao instaladas!"
echo ""
echo "Ola, bem vindo a instalaco do Looking Glass, preencha os campos abaixo com os Dados do provedor "
echo ""
read -p "Informe o nome do provedor: " name_isp
echo ""
read -p "Informe o ASN do provedor (Somente números ex: 270000): " asn_isp
    if ! [[ "$asn_isp" =~ ^[0-9]+$ ]]; then
        echo "❌ ASN invalido. Deve conter apenas números."
        exit 1
       fi
echo ""
read -p "Informe o IPV4 do roteador que ira utilizar
(exemplo: 45.168.168.20): " ip_roteador
if ! ipcalc -cs "$ip_roteador" >/dev/null 2>&1; then
    echo "❌ IPv4 invalido. Verifique se esta no formato correto e se e valido."
    exit 1
fi

echo ""
read -p "Informe o IPV6 do roteador que ira utilizar:
(exemplo: 2804:532C:0:1::131): " ipv6_roteador
if ! ipcalc -6cs "$ipv6_roteador" >/dev/null 2>&1; then
    echo "❌ IPv6 invalido. Verifique se esta no formato correto e se e valido."
    exit 1
fi
echo ""
read -p "Informe a porta SSH do do roteador:" port_ssh
if ! [[ "$port_ssh" =~ ^[0-9]{1,5}$ ]] || [ "$port_ssh" -lt 1 ] || [ "$port_ssh" -gt 65535 ]; then
    echo "❌ Porta SSH invalida. Deve conter ate 5 números entre 1 e 65535."
    exit 1
fi
echo ""
echo ""
read -p "Informe o site do cliente:(exemlo https://seusite.com.br) " site_isp
echo ""

 while true; do
           dialog --title "Logos do Provedor" --yesno "Voce ja tem as logos (.png) do provedor?" 8 60
        response=$?

        if [[ $response -eq 0 ]]; then
           question="s"
        else
           question="n"
        fi

      case "$question" in
        s)
          # Verifica imagem white
          while true; do
            whitelogo=$(dialog --title "Selecionar imagem white" --fselect /etc/ 14 60 3>&1 1>&2 2>&3)
            if [[ -f "$whitelogo" ]]; then
              dialog --msgbox "✅ Caminho encontrado com sucesso para a imagem white." 6 50
              break
            else
              dialog --msgbox "⚠️ Caminho invalido ou arquivo nao encontrado para a imagem white. Tente novamente." 6 60
            fi
          done
          # Verifica imagem dark
          while true; do
            darklogo=$(dialog --title "Selecionar imagem dark" --fselect /etc/ 14 60 3>&1 1>&2 2>&3)
            if [[ -f "$darklogo" ]]; then
              dialog --msgbox "✅ Caminho encontrado com sucesso para a imagem dark." 6 50
              break
            else
              dialog --msgbox "⚠️ Caminho invalido ou arquivo nao encontrado para a imagem dark. Tente novamente." 6 60
            fi
          done
          break
          ;;
        n)
          dialog --msgbox "A imagem e obrigatória para instalacao do Looking Glass.\nPor favor, baixe as imagens e inicie novamente o script!" 8 60
          clear
          exit 1
          ;;
        *)
          dialog --msgbox "⚠️ Opcao invalida!" 6 30
          ;;
      esac
    done

  while true; do
        dados_provedor="Nome do Provedor: $name_isp\nASN do Provedor: $asn_isp\nIPv4 do roteador: $ip_roteador\nIPv6 do roteador: $ipv6_roteador\nPorta SSH: $port_ssh\n\nImagem White: $whitelogo\nImagem Dark: $darklogo"
        dialog --title "Confirmacao dos Dados" --yesno "$dados_provedor\n\nOs dados estao corretos?" 15 70
        resposta=$?
        if [ $resposta -eq 0 ]; then
#   colocar aqui a edicao nos arquivos
            clear
            break
        else
                      while true; do
                          opcao=$(dialog --clear --stdout --title "Alterar Dados" \
                              --menu "Qual opcao deseja alterar?" 15 60 6 \
                              1 "Nome do Provedor" \
                              2 "ASN do Provedor" \
                              3 "IPv4 do Roteador" \
                              4 "IPv6 do Roteador" \
                              5 "Porta SSH" \
                              6 "Site Provedor"
                              7 "Cancelar")

                          case "$opcao" in
                              1)
                                  name_isp=$(dialog --stdout --inputbox "Informe o novo Nome do Provedor:" 8 60 "$name_isp")
                                  ;;
                              2)
                                  asn_isp=$(dialog --stdout --inputbox "Informe o novo ASN do Provedor:" 8 60 "$asn_isp")
                                  ;;
                              3)
                                  ip_roteador=$(dialog --stdout --inputbox "Informe o novo IPv4 do Roteador:" 8 60 "$ip_roteador")
                                  ;;
                              4)
                                  ipv6_roteador=$(dialog --stdout --inputbox "Informe o novo IPv6 do Roteador:" 8 60 "$ipv6_roteador")
                                  ;;
                              5)
                                  port_ssh=$(dialog --stdout --inputbox "Informe a nova porta SSH do Roteador" 8 60 "$port_ssh")
                                  ;;
                              6)
                                  site_isp=$(dialog --stdout --inputbox "Informe o novo site do Provedor" 8 60 "$site_isp")
                                  ;;
                              7)
                                  break
                                  ;;

                              *)
                                  dialog --msgbox "⚠️ Opcao invalida!" 6 30
                                  ;;
                          esac
                      done

                fi
  done

  clear
  echo "Iniciando a instalacao do Looking Glass..."
  echo "Instalando as dependencias..."
  apt install -y python3-dev python3-pip python3-pil python3-pil.imagetk \
  python3-libtiff python3-glymur libtiff-dev libfreetype-dev liblcms2-2 \
  liblcms2-utils libwebp-dev libboost-dev libimagequant-dev libraqm-dev \
  libjpeg-dev wget unzip zip git curl gnupg2 expect

  clear
  echo "Baixando os arquivos..."
  cd /tmp
  wget https://raw.githubusercontent.com/remontti/hyperglass/main/install.sh

   if [ -d "/root/hyperglass/static/" ]; then
     echo "⚠️ O diretório /root/hyperglass/static/ já existe. Instalação do Hyperglass será ignorada."
   else
     echo "📦 Instalando o Hyperglass... (Pode demorar alguns minutos)"
     bash install.sh
     hyperglass setup -d
      clear
        echo "Instalacao feita com sucesso!"
        sleep 2
   fi
  

  # Ajustando problema de webpack
  sed -i 's/webpack5: true,/webpack5: false,/g' /usr/local/lib/python3.10/dist-packages/hyperglass/ui/next.config.js

  echo "Movendo as imagens para o lugar correto..."
  if mv ~/LookingGlass_Custom/*.png /root/hyperglass/static/images; then
      echo "✅ Imagens movidas com sucesso!"
  else
      echo "❌ Falha ao mover as imagens. Fechando o script..."
      exit 1
  fi


  whitelogo=$(find /root/hyperglass/static/images -type f -iname "*white*.png" | head -n 1)
  darklogo=$(find /root/hyperglass/static/images -type f -iname "*dark*.png" | head -n 1)
  if [[ -z "$darklogo" ]]; then
    echo "Logo dark nao encontrada, usando a logo branca como fallback."
    darklogo="$whitelogo"
  fi


  machine_ip=$(hostname -I | awk '{for(i=1;i<=NF;i++) if ($i !~ /^127/ && $i !~ /^172\.17\./) {print $i; exit}}')

 clear
  if [[ -n "$machine_ip" ]]; then
    echo "O IP da máquina é: $machine_ip"
  else
    read -p "Não foi possível identificar o IP da máquina, por favor informe-o manualmente:" machine_ip
  fi
  
  echo "Declarando as variaveis..."
  sleep 3
  # Exporta as variaveis para o ambiente
  export name_isp asn_isp ip_roteador ipv6_roteador whitelogo darklogo port_ssh site_isp machine_ip


  echo "Substituindo as variaveis..."
  sleep 3
  envsubst < $file_hyperglass/hyperglass.yaml.template > $file_hyperglass/hyperglass.yaml
  envsubst < $file_hyperglass/devices.yaml.template > $file_hyperglass/devices.yaml

  # Validando existencia do arquivo .yaml
  if [[ ! -f "$file_hyperglass/hyperglass.yaml" || ! -f "$file_hyperglass/devices.yaml" ]]; then
      echo "Os arquivos '.yaml' nao foram substituídos"
      exit 1
  else
      echo "Substituicao feita com sucesso!"
  fi

  clear
  echo "Movendo o arquivo para o lugar correto..."
  if mv $file_hyperglass/*.yaml /root/hyperglass; then
      echo "✅ Arquivos movidos com sucesso!"
  else
      echo "❌ Falha ao mover os arquivos. Fechando o script..."
      exit 1
  fi


  echo "Iniciando o Hyperglass! (Pode demorar alguns minutos)"
  cd /root/hyperglass/
  hyperglass build-ui

  echo "Criando o servico do Hyperglass!"
  mkdir -p /root/hyperglass/service/

cat <<EOF > /root/hyperglass/service/hyperglass.service
[Unit]
Description=hyperglass
After=network.target
Requires=redis-server.service

[Service]
User=root
Group=root
ExecStart=/usr/local/bin/hyperglass start
ExecStop=/usr/bin/pkill -f hyperglass

TimeoutStartSec=120
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
EOF

  
ln -s /root/hyperglass/service/hyperglass.service /etc/systemd/system/hyperglass.service
  systemctl daemon-reload
  systemctl enable hyperglass

  if systemctl start hyperglass; then
      echo "✅ Hyperglass iniciado com sucesso!"
  else
      echo "❌ Falha ao iniciar o Hyperglass. Verifique com: journalctl -xe"
      exit 1
  fi
clear
echo "Reiniciando o serviço do Hyperglass..."
systemctl restart hyperglass
clear
systemctl status hyperglass
