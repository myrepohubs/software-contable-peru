# Guía Completa de Desarrollo: Conciliación Bancaria

Este documento sirve como guía para implementar la funcionalidad de **Conciliación Bancaria**, que permitirá a los usuarios subir extractos bancarios en formato Excel para compararlos con los registros internos del sistema.

## 1. Flujo de Trabajo Git: Crear la Rama

Comienza creando una rama dedicada para esta funcionalidad para mantener el trabajo aislado.

```bash
# 1. Asegúrate de estar en la rama principal y tener la última versión
git checkout main
git pull origin main

# 2. Crea y cambia a la nueva rama
git checkout -b feat/conciliacion-bancaria
```

## 2. Desarrollo del Backend (Java/Spring Boot)

### 2.1 Añadir Dependencia de Apache POI

Para leer archivos Excel (.xlsx), necesitamos la librería Apache POI. Añade la siguiente dependencia a tu archivo `pom.xml`:

```xml
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>5.2.3</version> <!-- O la versión estable más reciente -->
</dependency>
```

### 2.2 Controlador para la Subida de Archivos

Crea un controlador que gestione la subida del archivo de extracto bancario.

**`ConciliacionController.java`**
```java
package com.empresa.contable.conciliacion.controller;

import com.empresa.contable.conciliacion.service.ConciliacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/conciliacion")
public class ConciliacionController {

    @Autowired
    private ConciliacionService conciliacionService;

    @PostMapping("/upload")
    public ResponseEntity<String> uploadFile(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Por favor, selecciona un archivo para subir.");
        }
        try {
            conciliacionService.procesarExtractoBancario(file);
            return ResponseEntity.ok("Archivo procesado exitosamente.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al procesar el archivo: " + e.getMessage());
        }
    }
}
```

### 2.3 Servicio para Procesar el Excel

Este servicio contendrá la lógica principal para leer el archivo Excel usando Apache POI.

**`ConciliacionService.java`**
```java
package com.empresa.contable.conciliacion.service;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.Iterator;

@Service
public class ConciliacionService {

    /**
     * Procesa un archivo de extracto bancario en formato .xlsx.
     * Lee cada fila y la transforma en un objeto de transacción bancaria para su posterior procesamiento.
     * @param file El archivo Excel subido por el usuario.
     */
    public void procesarExtractoBancario(MultipartFile file) throws Exception {
        // Obtenemos el flujo de entrada del archivo para que Apache POI pueda leerlo.
        try (InputStream inputStream = file.getInputStream()) {
            // Creamos un Workbook (libro de trabajo) a partir del archivo.
            // XSSFWorkbook es para archivos .xlsx. Para .xls, se usaría HSSFWorkbook.
            XSSFWorkbook workbook = new XSSFWorkbook(inputStream);

            // Obtenemos la primera hoja del libro de trabajo.
            // Se asume que los datos están en la primera hoja (índice 0).
            XSSFSheet sheet = workbook.getSheetAt(0);

            // Obtenemos un iterador para recorrer todas las filas de la hoja.
            Iterator<Row> rowIterator = sheet.iterator();

            // Opcional: Omitimos la primera fila si es una cabecera.
            if (rowIterator.hasNext()) {
                rowIterator.next(); // Salta la fila de encabezado
            }

            // Iteramos sobre cada fila restante.
            while (rowIterator.hasNext()) {
                Row row = rowIterator.next();

                // Leemos los datos de las celdas (asumiendo un formato fijo)
                // Celda 0: Fecha, Celda 1: Descripción, Celda 2: Monto
                Cell fechaCell = row.getCell(0);
                Cell descripcionCell = row.getCell(1);
                Cell montoCell = row.getCell(2);

                // Aquí extraemos los valores. Es importante manejar diferentes tipos de celdas.
                // Por ejemplo, la fecha puede ser un tipo de dato específico de Excel.
                java.util.Date fecha = fechaCell.getDateCellValue();
                String descripcion = descripcionCell.getStringCellValue();
                double monto = montoCell.getNumericCellValue();
                
                System.out.printf("Fila leída: Fecha=%s, Desc.=%s, Monto=%.2f%n", fecha, descripcion, monto);

                // TODO: Lógica principal de conciliación.
                // 1. Crear un objeto TransaccionBancaria con los datos leídos.
                // 2. Buscar una transacción coincidente en los registros contables internos
                //    (ej. por monto y fecha aproximada).
                // 3. Si hay coincidencia, marcar ambas como "conciliadas".
                // 4. Si no, marcar la transacción bancaria como "no conciliada" para revisión manual.
            }
        }
    }
}
```

### 2.4 Guardar el Progreso del Backend

Realiza un commit con los cambios del backend y súbelos a la nueva rama.

```bash
git add .
git commit -m "feat(conciliacion): Add backend for Excel file processing"
git push --set-upstream origin feat/conciliacion-bancaria
```

## 3. Desarrollo del Frontend (React)

Crea un componente para que el usuario pueda subir el archivo y ver los resultados.

**`Conciliacion.js`**
```jsx
import React, { useState } from 'react';
import axios from 'axios';

function Conciliacion() {
    const [selectedFile, setSelectedFile] = useState(null);
    const [message, setMessage] = useState('');

    const handleFileChange = (event) => {
        setSelectedFile(event.target.files[0]);
    };

    const handleUpload = () => {
        if (!selectedFile) {
            setMessage('Por favor, selecciona un archivo.');
            return;
        }

        const formData = new FormData();
        formData.append('file', selectedFile);

        axios.post('/api/v1/conciliacion/upload', formData, {
            headers: {
                'Content-Type': 'multipart/form-data',
            },
        })
        .then(response => {
            setMessage(response.data);
            // TODO: Aquí podrías solicitar los resultados de la conciliación para mostrarlos.
        })
        .catch(error => {
            setMessage(error.response ? error.response.data : 'Error de red');
        });
    };

    return (
        <div>
            <h2>Conciliación Bancaria</h2>
            <p>Sube tu extracto bancario en formato Excel (.xlsx) para comenzar.</p>
            <input type="file" onChange={handleFileChange} accept=".xlsx" />
            <button onClick={handleUpload}>Procesar Archivo</button>
            
            {message && <p>{message}</p>}

            {/* TODO: Crear un componente para mostrar los resultados de la conciliación */}
            {/* Por ejemplo, tablas con transacciones conciliadas y no conciliadas. */}
        </div>
    );
}

export default Conciliacion;
```

### 3.1 Guardar el Progreso del Frontend

Añade los cambios del frontend al repositorio.

```bash
git add .
git commit -m "feat(conciliacion): Add frontend component for file upload"
git push
```

## 4. Finalización: Creación del Pull Request

Usa la siguiente plantilla para crear el Pull Request en GitHub.

> ---
>
> ## Título: Feat(Conciliacion): Implementación del Módulo de Conciliación Bancaria
>
> ### Descripción
> Este PR introduce la funcionalidad para subir y procesar extractos bancarios en formato Excel (.xlsx), sentando las bases para la conciliación automática y manual.
>
> ### Checklist de Cambios
> - [x] Backend: Creado endpoint para subida de archivos.
> - [x] Backend: Implementado servicio con Apache POI para leer archivos Excel.
> - [x] Frontend: Creado componente para seleccionar y subir el archivo.
>
> ### Instrucciones para Pruebas Manuales
> 1. Crea un archivo Excel simple con 3 columnas: Fecha, Descripción, Monto.
> 2. Navega a la nueva sección "Conciliación Bancaria".
> 3. Sube el archivo Excel creado.
> 4. Verifica que el backend responde con un mensaje de éxito y que los logs del servidor muestran los datos leídos de cada fila.
>
> ### Checklist de Aceptación (QA)
> - [ ] **Carga de Archivo Válido:** El sistema acepta y procesa un archivo `.xlsx` con el formato esperado.
> - [ ] **Rechazo de Archivo Inválido:** El sistema muestra un error si se intenta subir un archivo que no es `.xlsx` (verificar en frontend y backend).
> - [ ] **Coincidencia Automática (Simulado):** Los logs del backend indican que se está intentando buscar coincidencias para cada transacción leída.
> - [ ] **Interfaz para Conciliación Manual:** Se ha implementado un espacio en el frontend donde se mostrarán las transacciones no conciliadas para su manejo manual.
>
> ---
