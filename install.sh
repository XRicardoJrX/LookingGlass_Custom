#!/bin/bash
################################################################################
#      Script para instalação do Lookinglgass baseado no Hyperglass            #
# Utilizaçao> Execute o arquivo como root e escolha as opções                  #
#                                                                              #
#                                                                              #
#                                                                              #
#Autor: Ricardo Jr                                                             #
#Data: 15/04/205                                                               #
################################################################################

    echo "Olá, bem vindo a instalaço do Looking Glass, preencha os campos abaixo com os Dados do provedor "
    echo ""
    read -p "Informe o nome do provedor: " name_isp
    echo ""
    read -p "Informe o ASN do provedor (Somente números ex: 270000): " asn_isp
    echo ""
    read -p "Informe o IPV4 do roteador que irá utilizar
    (exemplo: 45.168.168.20): " ip_roteador
    echo ""
    read -p "Informe o IPV6 do roteador que irá utilizar:
    (exemplo: 2804:532C:0:1::131): " ipv6_roteador
    echo ""
    read -p "Informe a porta SSH do do roteador:" port_ssh
    echo ""
    echo "Confirme os dados abaixo: "
    echo "Nome do Provedor: $name_isp"
    echo "ASN do Provedor: $asn_isp"
    echo "IPv4 do roteador: $ip_roteador"
    echo "IPv6 do roteador: $ipv6_roteador"
    echo "Porta SSH: $port_ssh"
    echo ""
    echo ""
 while true; do
    read -p "Você já tem as logos (.png) do provedor?(s/n)" question
      case "$question" in
        s)
          # Verifica imagem white
          while true; do
            whitelogo=$(dialog --title "Selecionar imagem white" --fselect /etc/ 14 60 3>&1 1>&2 2>&3)
            if [[ -f "$whitelogo" ]]; then
              dialog --msgbox "✅ Caminho encontrado com sucesso para a imagem white." 6 50
              break
            else
              dialog --msgbox "⚠️ Caminho inválido ou arquivo não encontrado para a imagem white. Tente novamente." 6 60
            fi
          done
          # Verifica imagem dark
          while true; do
            darklogo=$(dialog --title "Selecionar imagem dark" --fselect /etc/ 14 60 3>&1 1>&2 2>&3)
            if [[ -f "$darklogo" ]]; then
              dialog --msgbox "✅ Caminho encontrado com sucesso para a imagem dark." 6 50
              break
            else
              dialog --msgbox "⚠️ Caminho inválido ou arquivo não encontrado para a imagem dark. Tente novamente." 6 60
            fi
          done
          break
          ;;
        n)
          dialog --msgbox "A imagem é obrigatória para instalação do Looking Glass.\nPor favor, baixe as imagens e inicie novamente o script!" 8 60
          clear
          ;;
        *)
          dialog --msgbox "⚠️ Opção inválida!" 6 30
          ;;
      esac
    done

  while true; do
        dados_provedor="Nome do Provedor: $name_isp\nASN do Provedor: $asn_isp\nIPv4 do roteador: $ip_roteador\nIPv6 do roteador: $ipv6_roteador\nPorta SSH: $port_ssh\n\nImagem White: $whitelogo\nImagem Dark: $darklogo"
        dialog --title "Confirmação dos Dados" --yesno "$dados_provedor\n\nOs dados estão corretos?" 15 70
        resposta=$?
        if [ $resposta -eq 0 ]; then
#   colocar aqui a edição nos arquivos
            clear
            break
        else
                      while true; do
                          opcao=$(dialog --clear --stdout --title "Alterar Dados" \
                              --menu "Qual opção deseja alterar?" 15 60 6 \
                              1 "Nome do Provedor" \
                              2 "ASN do Provedor" \
                              3 "IPv4 do Roteador" \
                              4 "IPv6 do Roteador" \
                              5 "Porta SSH" \
                              6 "Cancelar")

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
                                  break
                                  ;;
                              *)
                                  dialog --msgbox "⚠️ Opção inválida!" 6 30
                                  ;;
                          esac
                      done

                fi
  done

echo "Iniciando a instalaçao do Looking Glass..."
echo "Instalando as dependencias..."
apt install -y python3-dev python3-pip python3-pil python3-pil.imagetk\
 python3-libtiff python3-glymur libtiff-dev libfreetype-dev liblcms2-2\
 liblcms2-utils libwebp-dev libboost-dev libimagequant-dev libraqm-dev\
 libjpeg-dev wget unzip zip git curl gnupg2
echo "Baixando os arquivos..."
cd /tmp
wget https://raw.githubusercontent.com/remontti/hyperglass/main/install.sh
echo "Instalando o Hyperglass...(Pode demorar alguns minutos)"
bash install.sh
echo "/etc/hyperglass" | hyperglass setup
echo "Instalação feita com sucesso!"
sleep 2
echo "Declarando as variáveis..."
sleep 2
#Ajustando problema de webpack
sed -i 's/webpack5: true,/webpack5: false,/g' /usr/local/lib/python3.9/dist-packages/hyperglass/ui/next.config.js

# Exporta as variáveis para o ambiente
export name_isp asn_isp ip_roteador ipv6_roteador whitelogo darklogo port_ssh

echo "Substituindo as variáveis..."
sleep 2
  # Substitui variáveis nos templates
  envsubst < /home/ricardo/Documentos/PROJECT-LOOKING_GLASS-BKP/hyperglass.yaml.template > /home/ricardo/Documentos/PROJECT-LOOKING_GLASS-BKP/hyperglass.yaml
  envsubst < /home/ricardo/Documentos/PROJECT-LOOKING_GLASS-BKP/devices.yaml.template > /home/ricardo/Documentos/PROJECT-LOOKING_GLASS-BKP/devices.yaml
echo "Substituição feita com sucesso!"
echo ""
