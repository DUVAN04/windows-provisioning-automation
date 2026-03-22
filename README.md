# Windows 11 Custom Image: Deployment and Automation

Este repositorio contiene la metodología y las herramientas desarrolladas para automatizar el alistamiento de estaciones de trabajo mediante la captura de imágenes personalizadas de Windows 11. Este flujo de trabajo permite reducir los tiempos de configuración de **2 horas a 20 minutos** por equipo (una optimización del 80%).

## 1. Creación de la Imagen Base (Master)

Para garantizar la compatibilidad y evitar errores de clonación, el proceso se realiza sobre hardware físico utilizando el **Modo Auditoría** de Windows:

1.  **Instalación y Acceso**: Tras la instalación inicial, se ingresa al modo auditoría en la pantalla de bienvenida (OOBE) mediante la combinación `Ctrl + Shift + F3` o el comando `sysprep.exe /audit /reboot`.
2.  **Provisión de Software**: Se instalan las aplicaciones base corporativas estrictamente en la ruta `C:\Program Files` para asegurar la disponibilidad multiusuario.
    * *Nota*: Se identificó que aplicaciones con rutas de instalación dinámicas o agentes de seguridad específicos pueden generar errores durante el sellado del sistema.
3.  **Generalización (Sysprep)**: Se prepara el sistema para su distribución eliminando identificadores únicos (SID) con el comando:  
    `sysprep.exe /oobe /generalize /shutdown`.
4.  **Captura de Imagen (WIM)**: Mediante un entorno de pre-instalación (WinPE) desde una unidad USB, se captura la partición de sistema en un archivo `.wim` comprimido:  
    `dism /Capture-Image /ImageFile:D:\install.wim /CaptureDir:C:\ /Name:"W11_Custom" /Compress:max /CheckIntegrity`.

## 2. Automatización del Despliegue

Dada la inestabilidad de los archivos de respuesta XML en ciertos entornos, se implementó una solución basada en scripts para gestionar el ciclo completo de despliegue:

### A. Preparación y Aplicación (`Deployment_W11.bat`)
* **Gestión de Almacenamiento**: Automatización de `diskpart` para la limpieza del disco y estructuración de particiones GPT/UEFI (EFI 260MB, MSR y Primaria).
* **Aplicación de Imagen**: Despliegue de la imagen personalizada `install.wim` mediante `dism /Apply-Image`.
* **Configuración de Arranque**: Generación de archivos de inicio UEFI mediante `bcdboot`.
* **Inyección de Registro Offline**: Modificación del registro para omitir requisitos de red (BypassNRO) y configurar el AutoLogon inicial.
* **Post-Instalación**: Creación automática de la cuenta administrativa local a través de un script `SetupComplete.cmd`.

### B. Optimización de Sistema (`System_Optimization.bat`)
* **Identidad de Red**: Generación automática de *hostnames* basada en el número de serie único del BIOS extraído vía CIM.
* **Ajuste de Rendimiento (Kernel Tuning)**: Deshabilitación de la seguridad basada en virtualización (VBS/HVCI) y la compresión de memoria para maximizar la respuesta del CPU.
* **Debloat**: Remoción de aplicaciones preinstaladas (AppxPackages) y servicios no esenciales.
* **Detección de Hardware**: Identificación dinámica del fabricante (ej. Lenovo o Intel) para el despliegue automático de herramientas de gestión de drivers.
* **Integración y Seguridad**: Ejecución de la unión automática al dominio corporativo y reseteo de identificadores de herramientas de acceso remoto para evitar colisiones en la red.

## Resumen Técnico
* **Herramientas**: DISM, Diskpart, PowerShell, Batch.
* **Esquema de Particionado**: UEFI / GPT.
* **Resultado**: Despliegue estandarizado y optimizado, listo para producción en entornos de alta rotación.

**Autor:** Jorge Cardona  
Analista de Soporte HelpDesk | Estudiante de Ingeniería de Sistemas