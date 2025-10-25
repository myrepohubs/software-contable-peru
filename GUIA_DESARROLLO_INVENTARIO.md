# Guía Completa de Desarrollo: Módulo de Inventario

Este documento describe los pasos para implementar el **Módulo de Inventario** y su integración con el Módulo de Ventas, incluyendo la actualización de stock y la generación del costo de venta.

## 1. Flujo de Trabajo Git: Crear la Rama de Feature

Aísla el trabajo en una nueva rama para mantener un historial limpio.

```bash
# 1. Asegúrate de estar en la rama principal y tener la última versión
git checkout main
git pull origin main

# 2. Crea la nueva rama para esta funcionalidad
git checkout -b feat/module-inventario
```

## 2. Desarrollo del Backend (Java/Spring Boot)

La lógica clave aquí es la interacción entre el servicio de ventas y el nuevo servicio de inventario.

### 2.1 Crear Entidades y Repositorios de Inventario (Prerrequisitos)

Asegúrate de tener la entidad `Producto` y su repositorio.

**`Producto.java`**
```java
@Entity
@Data
public class Producto {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String sku;
    private String nombre;
    private int stock;
    private BigDecimal costoUnitario;
}
```
**`ProductoRepository.java`**
```java
public interface ProductoRepository extends JpaRepository<Producto, Long> {}
```

### 2.2 Crear el Nuevo `InventarioService.java`

Este servicio contendrá la lógica para actualizar el stock y generar el asiento contable del costo de venta.

```java
package com.empresa.contable.inventario.service;

import com.empresa.contable.venta.entity.Venta;
import com.empresa.contable.venta.entity.VentaItem;
import com.empresa.contable.inventario.entity.Producto;
import com.empresa.contable.inventario.repository.ProductoRepository;
// import com.empresa.contable.contabilidad.service.AsientoContableService; // Servicio hipotético
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;

@Service
public class InventarioService {

    @Autowired
    private ProductoRepository productoRepository;

    // @Autowired
    // private AsientoContableService asientoContableService;

    /**
     * Actualiza el stock de los productos vendidos y genera el asiento del costo de venta.
     * Este método se invoca después de que una venta ha sido confirmada.
     * @param venta La entidad Venta que acaba de ser registrada.
     */
    @Transactional
    public void actualizarStockYGenerarCostoVenta(Venta venta) {
        BigDecimal costoTotalVenta = BigDecimal.ZERO;

        for (VentaItem item : venta.getItems()) {
            Producto producto = productoRepository.findById(item.getProductoId())
                .orElseThrow(() -> new RuntimeException("Producto no encontrado: " + item.getProductoId()));

            // 1. Actualizar el stock
            int nuevoStock = producto.getStock() - item.getCantidad();
            if (nuevoStock < 0) {
                throw new RuntimeException("Stock insuficiente para el producto: " + producto.getNombre());
            }
            producto.setStock(nuevoStock);
            productoRepository.save(producto);
            
            // 2. Calcular el costo de este ítem de la venta
            BigDecimal costoItem = producto.getCostoUnitario().multiply(new BigDecimal(item.getCantidad()));
            costoTotalVenta = costoTotalVenta.add(costoItem);
        }

        // 3. Generar el asiento contable del costo de venta
        // ASIENTO DE COSTO DE VENTA
        // -------------------------------------------------------------
        // DEBE: 
        //   - Cuenta 69 (Costo de Ventas): costoTotalVenta
        // HABER:
        //   - Cuenta 20 (Mercaderías): costoTotalVenta
        // -------------------------------------------------------------
        System.out.println("Generando asiento de Costo de Venta por: " + costoTotalVenta);
        // asientoContableService.crearAsiento("Costo de Venta - Venta #" + venta.getId(), ...);
    }
}
```

### 2.3 Modificar el `VentaService.java` Existente

Inyecta `InventarioService` en `VentaService` y llámalo después de registrar una venta.

```java
package com.empresa.contable.venta.service;

import com.empresa.contable.inventario.service.InventarioService; // Importar el nuevo servicio
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class VentaService {
    
    @Autowired
    private VentaRepository ventaRepository;

    @Autowired
    private InventarioService inventarioService; // Inyectar el servicio de inventario

    @Transactional
    public Venta registrarVenta(Venta venta) {
        // ... (Lógica existente para validar y guardar la venta)
        Venta savedVenta = ventaRepository.save(venta);

        // --- NUEVA LÓGICA ---
        // Después de guardar la venta, actualizamos el inventario.
        inventarioService.actualizarStockYGenerarCostoVenta(savedVenta);
        // --------------------

        return savedVenta;
    }
}
```

### 2.4 Guardar el Progreso del Backend

Guarda los cambios en Git y súbelos a GitHub.

```bash
git add .
git commit -m "feat(inventario): Integrate stock update on sales and add cost of sales logic"
git push --set-upstream origin feat/module-inventario
```

## 3. Desarrollo del Frontend (React)

Crea las vistas necesarias para que el usuario interactúe con el inventario.

### 3.1 Vista de Gestión de Productos

Un componente para listar, crear y editar productos.

**`GestionProductos.js`**
```jsx
// Muestra una tabla con los productos y su stock actual.
// Incluye un botón para abrir un modal/formulario y crear un nuevo producto (SKU, Nombre, Stock Inicial, Costo).
// Cada fila de la tabla puede tener un botón de "Editar".
function GestionProductos() {
    // Lógica para obtener y mostrar productos desde /api/v1/productos
    return <div>...</div>;
}
```

### 3.2 Vista del Kardex de Producto

Un componente que muestra el historial de movimientos (entradas y salidas) de un producto específico.

**`KardexProducto.js`**
```jsx
// Recibe un 'productoId' como prop.
// Realiza una llamada a una API (ej. /api/v1/inventario/kardex/{productoId}) para obtener los movimientos.
// Muestra una tabla con: Fecha, Tipo (Entrada/Salida), Cantidad, Saldo.
function KardexProducto({ productoId }) {
    // ...
    return (
        <div>
            <h3>Kardex para Producto #{productoId}</h3>
            <table>
                <thead>
                    <tr><th>Fecha</th><th>Tipo</th><th>Entrada</th><th>Salida</th><th>Saldo</th></tr>
                </thead>
                <tbody>
                    {/* Mapear movimientos */}
                </tbody>
            </table>
        </div>
    );
}
```

### 3.3 Guardar el Progreso del Frontend

Guarda los cambios de frontend y actualiza la rama remota.

```bash
git add .
git commit -m "feat(inventario): Add product management and Kardex views"
git push
```

## 4. Finalización: Creación del Pull Request

Utiliza la siguiente plantilla para tu Pull Request.

> ---
>
> ## Título: Feat(Inventario): Gestión de Stock y Kardex
>
> ### Descripción
> Este PR implementa la funcionalidad central del módulo de inventario. Se integra con el proceso de ventas para actualizar automáticamente el stock y registrar el costo de venta. Además, se añaden las vistas para gestionar productos y visualizar el Kardex.
>
> ### Checklist de Cambios
> - [x] Backend: Creado `InventarioService` con la lógica de actualización de stock.
> - [x] Backend: Modificado `VentaService` para invocar la actualización de inventario.
> - [x] Frontend: Creada vista para la gestión de productos.
> - [x] Frontend: Creada vista para la visualización del Kardex.
>
> ### Instrucciones para Pruebas Manuales
> 1.  Ir a "Gestión de Productos" y crear un nuevo producto con **Stock Inicial = 20**.
> 2.  Ir al módulo de ventas y registrar una nueva venta de **5 unidades** de ese producto.
> 3.  Regresar a "Gestión de Productos" y verificar que el stock del producto ahora es **15**.
> 4.  Ir a la vista de "Kardex" para ese producto y verificar que existe un nuevo registro de "Salida" por 5 unidades.
> 5.  Revisar los logs del servidor para confirmar que se imprimió el mensaje "Generando asiento de Costo de Venta...".
>
> ### Checklist de Aceptación (QA)
> - [ ] **Disminución de Stock:** Al realizar una venta, el stock del producto vendido disminuye correctamente.
> - [ ] **Validación de Stock:** El sistema impide una venta si no hay stock suficiente y muestra un error claro.
> - [ ] **Actualización del Kardex:** La venta genera un registro de "Salida" en el Kardex del producto correspondiente.
> - [ ] **Generación de Costo de Venta:** Los logs del backend confirman que se calcula e intenta registrar el asiento de costo de venta.
> - [ ] **Regresión - Ventas:** El proceso de venta sigue funcionando para productos que no manejan inventario (si aplica).
> - [ ] **Regresión - Clientes:** El CRUD de clientes no se ve afectado.
>
> ---
