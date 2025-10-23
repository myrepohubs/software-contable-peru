#!/bin/bash

# ==============================================================================
# Script de Guía de Flujo de Trabajo: Backend
# ==============================================================================
# Este script guía al usuario a través de un flujo de trabajo de desarrollo
# para agregar una nueva funcionalidad al backend (módulo de clientes).
#
# PRERREQUISITO: Debe ejecutarse desde la raíz del proyecto 'software-contable-peru'.
#
# El script realizará las siguientes acciones:
# 1. Sincronizará con la rama 'main' remota.
# 2. Creará una nueva rama de feature: 'feat/module-clientes'.
# 3. Generará los archivos Java (Entidad, Repositorio, Controlador) para Clientes.
# 4. Confirmará los cambios en un commit y subirá la rama a GitHub.
# ==============================================================================

# --- Configuración de Colores (Desactivados) ---
GREEN=""
YELLOW=""
BLUE=""
RED=""
NC=""

# --- Variables de Flujo ---
PROJECT_NAME="software-contable-peru"
BRANCH_NAME="feat/module-clientes"
BASE_JAVA_PATH="backend/src/main/java/com/empresa/contable"

# Detener el script si un comando falla
set -e

# --- Inicio del Script ---
echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}  Asistente de Flujo de Trabajo de Desarrollo (Backend)             ${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo

# --- Verificación de Entorno ---
echo -e "${YELLOW}Verificando el entorno de trabajo...${NC}"
if [ ! -d ".git" ] || [ "$(basename "$PWD")" != "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Este script debe ser ejecutado desde la raíz del directorio del proyecto '$PROJECT_NAME'.${NC}"
    echo "Por favor, navega al directorio correcto e inténtalo de nuevo (ej: cd $PROJECT_NAME)."
    exit 1
fi
echo -e "${GREEN}¡Estás en el directorio correcto del proyecto!${NC}"
echo

# --- PASO 1: Sincronizar y Crear Nueva Rama ---
echo -e "${YELLOW}--- PASO 1: Sincronizar y Crear Nueva Rama ---${NC}"

echo "-> Cambiando a la rama 'main' para asegurar que partimos de la base más reciente."
git checkout main

echo "-> Descargando los últimos cambios de la rama 'main' desde GitHub."
git pull origin main

echo "-> Creando y cambiando a una nueva rama para la funcionalidad de Clientes: '${BRANCH_NAME}'"
# Comprobamos si la rama ya existe
if git show-ref --quiet "refs/heads/${BRANCH_NAME}"; then
  echo -e "${YELLOW}La rama '${BRANCH_NAME}' ya existe.${NC}"
  read -p "¿Deseas eliminarla y crearla de nuevo para empezar de cero? (s/N): " choice
  if [[ "$choice" =~ ^[Ss]$ ]]; then
    echo "Eliminando y recreando la rama..."
    git branch -D "${BRANCH_NAME}"
    git checkout -b "${BRANCH_NAME}"
  else
    echo "Cambiando a la rama existente..."
    git checkout "${BRANCH_NAME}"
  fi
else
  git checkout -b "${BRANCH_NAME}"
fi

echo -e "${GREEN}¡Listo! Ahora estás trabajando en la rama '${BRANCH_NAME}'.${NC}"
echo
read -p "Presiona [Enter] para continuar con la generación de código..."

# --- PASO 2: Generar Código Backend ---
echo
echo -e "${YELLOW}--- PASO 2: Generando el código para el módulo de Clientes ---${NC}"

# Crear estructura de directorios para el módulo de clientes
CLIENTE_PATH="${BASE_JAVA_PATH}/cliente"
mkdir -p "${CLIENTE_PATH}/entity"
mkdir -p "${CLIENTE_PATH}/repository"
mkdir -p "${CLIENTE_PATH}/controller"
echo "-> Estructura de directorios creada en: ${CLIENTE_PATH}"

# Generar la Entidad Cliente
echo "-> Creando la entidad: Cliente.java"
cat << 'EOF' > "${CLIENTE_PATH}/entity/Cliente.java"
package com.empresa.contable.cliente.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Column;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;

    @Column(unique = true, nullable = false)
    private String ruc;

    private String direccion;

    private String telefono;
}
EOF

# Generar el Repositorio Cliente
echo "-> Creando el repositorio: ClienteRepository.java"
cat << 'EOF' > "${CLIENTE_PATH}/repository/ClienteRepository.java"
package com.empresa.contable.cliente.repository;

import com.empresa.contable.cliente.entity.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Long> {
}
EOF

# Generar el Controlador Cliente
echo "-> Creando el controlador: ClienteController.java"
cat << 'EOF' > "${CLIENTE_PATH}/controller/ClienteController.java"
package com.empresa.contable.cliente.controller;

import com.empresa.contable.cliente.entity.Cliente;
import com.empresa.contable.cliente.repository.ClienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/clientes")
public class ClienteController {

    @Autowired
    private ClienteRepository clienteRepository;

    @GetMapping
    public List<Cliente> getAllClientes() {
        return clienteRepository.findAll();
    }

    @PostMapping
    public Cliente createCliente(@RequestBody Cliente cliente) {
        return clienteRepository.save(cliente);
    }
}
EOF

echo -e "${GREEN}¡Código base para el módulo de Clientes generado exitosamente!${NC}"
echo
read -p "Presiona [Enter] para guardar los cambios en Git..."

# --- PASO 3: Commit y Push de la Rama ---
echo
echo -e "${YELLOW}--- PASO 3: Guardando y subiendo los cambios a GitHub ---${NC}"

echo "-> Añadiendo todos los archivos nuevos y modificados al área de preparación (staging)."
git add .

echo "-> Realizando un commit atómico con un mensaje descriptivo."
git commit -m "feat(clientes): Add backend for Clientes module"

echo "-> Subiendo la nueva rama '${BRANCH_NAME}' al repositorio remoto en GitHub."
git push origin "${BRANCH_NAME}"

echo
echo -e "${GREEN}======================================================================${NC}"
echo -e "${GREEN}  ¡Flujo de trabajo completado con éxito!                             ${NC}"
echo -e "${GREEN}======================================================================${NC}"
echo
echo "Resumen de lo que se hizo:"
echo "1. Se creó y cambió a la rama '${BRANCH_NAME}'."
echo "2. Se generaron los archivos Java para la entidad, repositorio y controlador de Cliente."
echo "3. Se subieron los cambios a GitHub en la nueva rama."
echo
echo "Ahora puedes ir a GitHub y verás la sugerencia para crear un 'Pull Request' desde '${BRANCH_NAME}' hacia 'main'."
echo
