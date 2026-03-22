# Windows 11 Automated Provisioning and System Optimization

Este repositorio contiene un conjunto de herramientas de automatización desarrolladas para optimizar el ciclo de vida de despliegue de estaciones de trabajo en entornos corporativos. Mediante el uso de Batch scripting, PowerShell (CIM/WMI) y manipulación directa del Registro de Windows, se logró una reducción del 80% en los tiempos de alistamiento, pasando de 120 a 20 minutos por equipo.

## Impacto Operativo

* **Eficiencia operativa**: Automatización completa del particionado de disco y aplicación de imágenes base.
* **Personalización Offline**: Configuración de parámetros de sistema críticos antes de la carga inicial del sistema operativo (OOBE Bypass).
* **Inteligencia de Hardware**: Detección dinámica del fabricante mediante consultas al BIOS para la provisión automatizada de drivers.
* **Estandarización de Flotas**: Garantía de configuraciones de seguridad, rendimiento y cumplimiento normativo uniformes en todo el parque tecnológico.

## Desglose Técnico

### 1. Despliegue de Imagen (Deployment_W11.bat)
Script diseñado para la fase de pre-instalación en entornos de ejecución WinPE.

* **Gestión de Almacenamiento**: Inicialización y estructuración de discos bajo esquema GPT/UEFI mediante la utilidad Diskpart.
* **Despliegue de Imagen**: Aplicación de archivos de imagen (.wim) utilizando el motor DISM con verificación de integridad y activación del modo compacto para eficiencia de almacenamiento.
* **Inyección de Registro Offline**: Modificación de las colmenas (hives) de registro del sistema antes del arranque inicial para omitir los requisitos de red (NRO Bypass) y configurar el auto-logon de cuentas administrativas locales.

### 2. Post-Aprovisionamiento y Optimización (System_Optimization.bat)
Script de ejecución post-instalación enfocado en el endurecimiento (hardening) y ajuste de rendimiento del sistema.

* **Identidad Dinámica**: Generación automática de hostnames basada en el número de serie único extraído del BIOS a través de instancias CIM.
* **Kernel Tuning**: Deshabilitación de la seguridad basada en virtualización (VBS/HVCI) para reducir el overhead del CPU y optimización de la gestión de memoria (Memory Compression).
* **Debloat y Reducción de Superficie de Ataque**: Remoción selectiva de aplicaciones preinstaladas (AppxPackages) y deshabilitación de servicios no esenciales para mejorar la respuesta del sistema y minimizar riesgos de seguridad.
* **Automatización de Directorio Activo**: Lógica de verificación de estado y unión automática al dominio mediante el manejo de objetos de credenciales en PowerShell.

## Seguridad y Mejores Prácticas

* **Sanitización de Datos**: El código ha sido auditado para eliminar cualquier referencia a credenciales críticas, nombres de dominio reales o identificadores corporativos específicos.
* **Control de Idempotencia**: El sistema incluye lógica de validación para verificar si el equipo ya ha sido procesado, evitando ejecuciones duplicadas en el Directorio Activo.
* **Gestión de Identificadores Únicos**: Incluye procedimientos para forzar la regeneración de IDs en herramientas de acceso remoto (AnyDesk), garantizando que cada equipo desplegado mantenga una identidad única en la red.

## Autor
**Jorge Cardona** Analista de Soporte HelpDesk | Estudiante de Ingeniería de Sistemas
