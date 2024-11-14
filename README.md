<a id="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">DEV ENV AUTOMATE</h3>

  <p align="center">
    Configuration for my personal development environment 
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

Aquí existen los scripts para automatizar el proceso de configuración de mi entorno de desarrollo para Windows con WSL2.

### Built With

[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)][Bash-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

This is how to get the software up and running locally.

### Prerequisites

This section lists all the prerequisites that you need to install before you can run the scripts.

- WSL2
  ```sh
  wsl --install -d Debian
  ```

### Installation

1. Open your terminal with WSL2 and run the following command
   ```sh
   sudo apt update; sudo apt -y upgrade; sudo apt install -y curl wget; \
   bash <(curl -s https://raw.githubusercontent.com/Edd27/wsl2-devenv-setup/main/1-update.sh)
   ```
2. Then run the following command
   ```sh
   zsh -i <(curl -s https://raw.githubusercontent.com/Edd27/wsl-devenv-setup/main/2-configure.sh)
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Edgar Benavides - [@EddDevJs](https://x.com/EddDevJs) - contacto@edgarbenavides.dev

Project Link: [https://github.com/Edd27/wsl2-devenv-setup](https://github.com/Edd27/wsl2-devenv-setup)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[Bash-url]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
