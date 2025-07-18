<a id="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Edd27/devenv-setup">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">DEVENV</h3>

  <p align="center">
    Script to automate the setup of a development environment on Linux and WSL2
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About</a>
      <ul>
        <li><a href="#built-with">Built with</a></li>
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

## About the project

Here you will find scripts to automate the setup process of development environment for Windows with WSL2, Debian and Ubuntu.

### Built with

[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)][Bash-url]

<p align="right">(<a href="#readme-top">Back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

Here is everything you need to start running the setup scripts.

### Prerequisites

This section lists the prerequisites to run the setup scripts.

- One of the following operating systems:
  - Windows / WSL2
  - Debian
  - Ubuntu

### Installation

1. Clone the repository
  ```sh
  sudo apt update && \
  sudo apt install git -y && \
  git clone https://github.com/Edd27/devenv-setup.git
  ```

2. Change to the cloned directory
  ```sh
  cd devenv-setup
  ```

3. Make the setup script executable
  ```sh
  chmod +x setup.sh
  ```

4. Run the setup script
  ```sh
  ./setup.sh
  ```

<p align="right">(<a href="#readme-top">Back to top</a>)</p>

<!-- CONTACT -->

## Contact

Edgar Benavides - [@EddDevJs](https://x.com/EddDevJs) - contacto@edgarbenavides.dev

Project link: [https://github.com/Edd27/devenv-setup](https://github.com/Edd27/devenv-setup)

<p align="right">(<a href="#readme-top">Back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[Bash-url]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
