<a id="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Edd27/devenv-setup">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">DEV ENV AUTOMATE</h3>

  <p align="center">
    Scripts de configuracion automatizada para mi entorno de desarrollo como Ingeniero de Software 
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Tabla de contenido</summary>
  <ol>
    <li>
      <a href="#about-the-project">Acerca del proyecto</a>
      <ul>
        <li><a href="#built-with">Desarrollado con</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Iniciando</a>
      <ul>
        <li><a href="#prerequisites">Prerequisitos</a></li>
        <li><a href="#installation">Instalacion</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contacto</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## Acerca del proyecto

Aquí existen los scripts para automatizar el proceso de configuración de mi entorno de desarrollo para Windows con WSL2.

### Desarrollado con

[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)][Bash-url]

<p align="right">(<a href="#readme-top">Ir a inicio</a>)</p>

<!-- GETTING STARTED -->

## Comenzando

Aqui esta todo lo necesario para iniciar con la ejecucion de los scripts

### Prerequisitos

En esta seccion se listan los prerequisitos para poder ejecutar los scripts de configuracion

- Alguno de estos sistemas operativos:
  - Windows con WSL2
    ```sh
    wsl --install Debian
    ```
  - Linux (Ubuntu o Debian)

- ZSH como shell por defecto
  1. Instalar ZSH
    ```sh
    sudo apt install zsh; \
      zsh --version; \
      chsh -s $(which zsh)
    ```
  2. Recargar la terminal.

### Instalacion

1. Abre la terminal y ejecuta el siguiente comando
  - Linux
    ```sh
    sudo apt update; sudo apt -y upgrade; sudo apt install -y curl; \
    curl -sSL https://raw.githubusercontent.com/Edd27/devenv-setup/main/setup.sh | zsh -i
    ```
  - macOS
    ```sh
    curl -sSL https://raw.githubusercontent.com/Edd27/devenv-setup/main/setup.sh | zsh -i
    ```

<p align="right">(<a href="#readme-top">Ir a inicio</a>)</p>

<!-- CONTACT -->

## Contacto

Edgar Benavides - [@EddDevJs](https://x.com/EddDevJs) - contacto@edgarbenavides.dev

Enlace del proyecto: [https://github.com/Edd27/devenv-setup](https://github.com/Edd27/devenv-setup)

<p align="right">(<a href="#readme-top">Ir a inicio</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[Bash-url]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
