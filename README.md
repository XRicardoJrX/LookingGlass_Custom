# Instalação Automática do Hyperglass

Este repositório contém um script automatizado para instalação e configuração do [hyperglass](https://github.com/hyperglass/hyperglass), uma ferramenta de looking glass moderna para redes.

> **Atenção:** Este script é de propriedade de **Ricardo Mori**.  
> Qualquer modificação ou uso não autorizado pode comprometer a operação.  
> Em caso de necessidade ou caso encontre algum problema, favor abrir uma nova **issue** com sua dúvida ou relato de bug.

---

## 🚀 Funcionalidades

- Instalação automatizada do Hyperglass
- Configuração básica e personalizada
- Criação de serviço systemd
- Suporte a logos customizados
- Compatibilidade com Python 3.10+

---

## ✅ Requisitos

- Sistema baseado em Debian/Ubuntu
- Python 3.10 ou superior
- `dialog`, `expect`, `git`, `curl` e outros utilitários comuns

---

## 🔧 Instalação

```bash
git clone https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
cd SEU_REPOSITORIO
chmod +x install.sh
sudo ./install.sh
