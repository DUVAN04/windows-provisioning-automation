# [cite_start]Windows 11 Custom Image: Deployment and Automation [cite: 1, 2, 3]

[cite_start]Este repositorio contiene la metodología y las herramientas desarrolladas para automatizar el alistamiento de estaciones de trabajo mediante la captura de imágenes personalizadas de Windows 11[cite: 1, 2, 3]. [cite_start]Este flujo de trabajo permite reducir los tiempos de configuración de **2 horas a 20 minutos** por equipo (una optimización del 80%)[cite: 1, 2, 3].

## [cite_start]1. Creación de la Imagen Base (Master) [cite: 1, 2, 3]

[cite_start]Para garantizar la compatibilidad y evitar errores de clonación, el proceso se realiza sobre hardware físico utilizando el **Modo Auditoría** de Windows[cite: 1, 2, 3]:

1.  [cite_start]**Instalación y Acceso**: Tras la instalación inicial, se ingresa al modo auditoría en la pantalla de bienvenida (OOBE) mediante la combinación `Ctrl + Shift + F3` o el comando `sysprep.exe /audit /reboot`[cite: 1, 2, 3].
2.  [cite_start]**Provisión de Software**: Se instalan las aplicaciones base corporativas estrictamente en la ruta `C:\Program Files` para asegurar la disponibilidad multiusuario[cite: 1, 2, 3].
    * [cite_start]*Nota*: Se identificó que aplicaciones con rutas de instalación dinámicas o agentes de seguridad específicos pueden generar errores durante el sellado del sistema[cite: 1, 2, 3].
3.  **Generalización (Sysprep)**: Se prepara el sistema para su distribución eliminando identificadores únicos (SID) con el comando:  
    [cite_start]`sysprep.exe /oobe /generalize /shutdown`[cite: 1, 2, 3].
4.  **Captura de Imagen (WIM)**: Mediante un entorno de pre-instalación (WinPE) desde una unidad USB, se captura la partición de sistema en un archivo `.wim` comprimido:  
    `dism /Capture-Image /ImageFile:D:\install.wim /CaptureDir:C:\ /Name:"W11_Custom" /Compress:max /CheckIntegrity`[cite: 1, 2, 3].

## [cite_start]2. Automatización del Despliegue [cite: 1, 2, 3]

[cite_start]Dada la inestabilidad de los archivos de respuesta XML en ciertos entornos, se implementó una solución basada en scripts para gestionar el ciclo completo de despliegue[cite: 1, 2, 3]:

### [cite_start]A. Preparación y Aplicación (`Deployment_W11.bat`) [cite: 1, 2, 3]
* [cite_start]**Gestión de Almacenamiento**: Automatización de `diskpart` para la limpieza del disco y estructuración de particiones GPT/UEFI (EFI 260MB, MSR y Primaria)[cite: 1, 2].
* [cite_start]**Aplicación de Imagen**: Despliegue de la imagen personalizada `install.wim` mediante `dism /Apply-Image`[cite: 2].
* [cite_start]**Configuración de Arranque**: Generación de archivos de inicio UEFI mediante `bcdboot`[cite: 3].
* [cite_start]**Inyección de Registro Offline**: Modificación del registro para omitir requisitos de red (BypassNRO) y configurar el AutoLogon inicial[cite: 2].
* [cite_start]**Post-Instalación**: Creación automática de la cuenta administrativa local a través de un script `SetupComplete.cmd`[cite: 3].

### [cite_start]B. Optimización de Sistema (`System_Optimization.bat`) [cite: 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
* [cite_start]**Identidad de Red**: Generación automática de *hostnames* basada en el número de serie único del BIOS extraído vía CIM[cite: 5, 6].
* [cite_start]**Ajuste de Rendimiento (Kernel Tuning)**: Deshabilitación de la seguridad basada en virtualización (VBS/HVCI) y la compresión de memoria para maximizar la respuesta del CPU[cite: 11].
* [cite_start]**Debloat**: Remoción de aplicaciones preinstaladas (AppxPackages) y servicios no esenciales[cite: 7, 12].
* [cite_start]**Detección de Hardware**: Identificación dinámica del fabricante (ej. Lenovo o Intel) para el despliegue automático de herramientas de gestión de drivers[cite: 9, 10].
* [cite_start]**Integración y Seguridad**: Ejecución de la unión automática al dominio corporativo y reseteo de identificadores de herramientas de acceso remoto para evitar colisiones en la red[cite: 13, 14, 15, 16, 17, 18, 19].

## [cite_start]Resumen Técnico [cite: 1, 2, 3, 5, 11]
* [cite_start]**Herramientas**: DISM, Diskpart, PowerShell, Batch[cite: 1, 2, 3, 5, 11].
* [cite_start]**Esquema de Particionado**: UEFI / GPT[cite: 1].
* [cite_start]**Resultado**: Despliegue estandarizado y optimizado, listo para producción en entornos de alta rotación[cite: 1, 2, 3].

**Autor:** Jorge Cardona  
Analista de Soporte HelpDesk | [cite_start]Estudiante de Ingeniería de Sistemas [cite: 1, 2, 3]