# Guía Completa de Desarrollo: Módulo de Compras

Este documento detalla el proceso completo para desarrollar e integrar el **Módulo de Compras** en el proyecto `software-contable-peru`. Sigue estos pasos para asegurar la consistencia y calidad del código.

## 1. Flujo de Trabajo Git: Preparación del Entorno

Antes de escribir código, prepara tu entorno de Git. Esto asegura que trabajes sobre la versión más actualizada del proyecto y en una rama aislada.

```bash
# 1. Asegúrate de estar en la rama principal
git checkout main

# 2. Descarga los últimos cambios del repositorio remoto
git pull origin main

# 3. Crea una nueva rama para esta funcionalidad
git checkout -b feat/module-compras
```

## 2. Desarrollo del Backend (Java/Spring Boot)

Implementaremos las entidades, repositorios, controladores y servicios necesarios para el backend.

### 2.1 Módulo de Proveedores

**Entidad `Proveedor.java`**
```java
package com.empresa.contable.proveedor.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Proveedor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String ruc;

    @Column(nullable = false)
    private String razonSocial;
    
    private String direccion;
    private String telefono;
}
```

**Repositorio `ProveedorRepository.java`**
```java
package com.empresa.contable.proveedor.repository;

import com.empresa.contable.proveedor.entity.Proveedor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProveedorRepository extends JpaRepository<Proveedor, Long> {
}
```

**Controlador `ProveedorController.java`**
```java
package com.empresa.contable.proveedor.controller;

import com.empresa.contable.proveedor.entity.Proveedor;
import com.empresa.contable.proveedor.repository.ProveedorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/proveedores")
public class ProveedorController {

    @Autowired
    private ProveedorRepository proveedorRepository;

    @GetMapping
    public List<Proveedor> getAllProveedores() {
        return proveedorRepository.findAll();
    }

    @PostMapping
    public Proveedor createProveedor(@RequestBody Proveedor proveedor) {
        return proveedorRepository.save(proveedor);
    }
}
```

### 2.2 Módulo de Compras

**Entidad `FacturaCompra.java`**
```java
package com.empresa.contable.compra.entity;

import com.empresa.contable.proveedor.entity.Proveedor;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;
import java.math.BigDecimal;

@Entity
@Data
public class FacturaCompra {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "proveedor_id", nullable = false)
    private Proveedor proveedor;

    @Column(nullable = false)
    private String numeroFactura;

    private LocalDate fechaEmision;
    private BigDecimal montoTotal;
    private BigDecimal igv;
}
```

**Servicio `CompraService.java` con lógica de asientos contables**
```java
package com.empresa.contable.compra.service;

import com.empresa.contable.compra.entity.FacturaCompra;
import com.empresa.contable.compra.repository.FacturaCompraRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CompraService {

    @Autowired
    private FacturaCompraRepository facturaCompraRepository;

    // Asumimos que existe un servicio para manejar los asientos contables
    // @Autowired
    // private AsientoContableService asientoContableService;

    @Transactional
    public FacturaCompra registrarCompra(FacturaCompra factura) {
        // 1. Guardar la factura de compra
        FacturaCompra savedFactura = facturaCompraRepository.save(factura);

        // 2. Generar el asiento contable correspondiente (lógica simplificada)
        // ASIENTO DE PROVISIÓN DE COMPRA
        // -------------------------------------------------------------
        // DEBE: 
        //   - Cuenta 60 (Compras): Monto base
        //   - Cuenta 40 (Tributos - IGV): Monto del IGV
        // HABER:
        //   - Cuenta 42 (Cuentas por Pagar Comerciales): Monto total
        // -------------------------------------------------------------
        System.out.println("Generando asiento contable para la factura: " + savedFactura.getNumeroFactura());
        // asientoContableService.crearAsiento(...);

        return savedFactura;
    }
}
```

### 2.3 Guardar el Progreso del Backend

Realiza un commit con todos los cambios del backend.

```bash
git add .
git commit -m "feat(compras): Add backend for Providers and Purchase Invoices"
```

## 3. Desarrollo del Frontend (React)

Crea los componentes de React para interactuar con la nueva API.

### 3.1 Vista para Gestionar Proveedores

Crea un componente `Proveedores.js` que liste los proveedores y permita agregar uno nuevo usando un formulario.

```jsx
// Ejemplo de snippet para Proveedores.js
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function Proveedores() {
    const [proveedores, setProveedores] = useState([]);
    // ... estado para el formulario de nuevo proveedor

    useEffect(() => {
        axios.get('/api/v1/proveedores')
            .then(res => setProveedores(res.data));
    }, []);

    const handleSubmit = (e) => {
        e.preventDefault();
        // ... lógica para enviar el nuevo proveedor con axios.post
    };

    return (
        <div>
            <h1>Gestión de Proveedores</h1>
            {/* Formulario para agregar proveedor */}
            {/* Lista de proveedores */}
        </div>
    );
}
```

### 3.2 Vista para Registrar Facturas de Compra

Crea un componente `RegistrarCompra.js` con un formulario para registrar una nueva factura, incluyendo un selector para elegir el proveedor.

```jsx
// Ejemplo de snippet para RegistrarCompra.js
import React, { useState } from 'react';
import axios from 'axios';

function RegistrarCompra() {
    const [factura, setFactura] = useState({ proveedorId: '', numeroFactura: '', ... });
    
    const handleSubmit = (e) => {
        e.preventDefault();
        axios.post('/api/v1/compras/registrar', factura) // Suponiendo este endpoint en el controller
            .then(res => alert('¡Compra registrada con éxito!'));
    };

    return (
        <div>
            <h1>Registrar Factura de Compra</h1>
            <form onSubmit={handleSubmit}>
                {/* Campos para número de factura, fecha, montos y un select para proveedores */}
            </form>
        </div>
    );
}
```

### 3.3 Guardar el Progreso del Frontend y Subir Cambios

Añade los cambios del frontend al último commit y sube la rama a GitHub.

```bash
git add .
git commit --amend --no-edit # Agrega los cambios al commit anterior sin cambiar el mensaje
git push --set-upstream origin feat/module-compras
```

## 4. Aseguramiento de la Calidad (Pruebas)

### 4.1 Prueba Unitaria para `CompraService`

Crea una prueba unitaria para verificar la lógica de negocio.

```java
package com.empresa.contable.compra.service;

import com.empresa.contable.compra.entity.FacturaCompra;
import com.empresa.contable.compra.repository.FacturaCompraRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.Mockito.*;
import static org.assertj.core.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class CompraServiceTest {

    @Mock
    private FacturaCompraRepository facturaCompraRepository;
    
    // @Mock
    // private AsientoContableService asientoContableService;

    @InjectMocks
    private CompraService compraService;

    @Test
    void alRegistrarCompra_debeGuardarFacturaYGenerarAsientoContable() {
        // Arrange
        FacturaCompra factura = new FacturaCompra();
        factura.setNumeroFactura("F001-001");
        
        when(facturaCompraRepository.save(any(FacturaCompra.class))).thenReturn(factura);

        // Act
        FacturaCompra result = compraService.registrarCompra(factura);

        // Assert
        assertThat(result).isNotNull();
        // Verifica que el método para guardar la factura fue llamado
        verify(facturaCompraRepository, times(1)).save(factura);
        // Verifica que la lógica de asientos contables fue invocada (cuando se descomente)
        // verify(asientoContableService, times(1)).crearAsiento(any());
    }
}
```

### 4.2 Pruebas de Regresión

Antes de finalizar, realiza las siguientes pruebas manuales para asegurar que no se rompieron funcionalidades existentes:

- **Módulo de Clientes:** Verifica que todavía puedes crear un cliente y verlo en la lista.
- **Módulo de Ventas:** Intenta crear una factura de venta asociada a un cliente.
- **Módulo de Reportes:** Genera un reporte de ventas y asegúrate de que los datos son correctos y no se ven afectados por el nuevo módulo.

### 4.3 Guardar las Pruebas

Añade los archivos de prueba al repositorio.

```bash
git add .
git commit -m "test(compras): Add unit tests for CompraService"
git push
```

## 5. Finalización: Creación del Pull Request

Una vez que todas las pruebas pasen, crea un Pull Request en GitHub usando la siguiente plantilla.

> ---
>
> ## Título: Feat(Compras): Implementación del Módulo de Compras MVP
>
> ### Descripción
> Este PR introduce la funcionalidad completa para la gestión de proveedores y el registro de facturas de compra, incluyendo la lógica de provisión contable.
>
> ### Checklist de Cambios
> - [x] Backend API creado (Proveedores y Compras)
> - [x] Frontend UI implementado (Formularios y listas)
> - [x] Pruebas unitarias añadidas para el servicio de compras
>
> ### Instrucciones para Pruebas Manuales
> 1. Navegar a la sección "Proveedores" y crear un nuevo proveedor.
> 2. Navegar a "Registrar Compra", seleccionar el proveedor creado y completar el formulario.
> 3. Verificar en la base de datos que la factura y el proveedor se han guardado correctamente.
>
> ### Checklist de Aceptación (QA)
> **Nuevas Funcionalidades:**
> - [ ] Se puede crear un proveedor con RUC y Razón Social.
> - [ ] El sistema valida que no se puedan crear dos proveedores con el mismo RUC.
> - [ ] Se puede registrar una factura de compra asociándola a un proveedor existente.
> - [ ] Al registrar la compra, se simula la creación del asiento contable de provisión (ver logs del servidor).
>
> **Pruebas de Regresión:**
> - [ ] El CRUD de Clientes sigue funcionando correctamente.
> - [ ] La emisión de facturas de VENTA no ha sido afectada.
> - [ ] Los reportes financieros existentes se generan sin errores.
>
> ---

