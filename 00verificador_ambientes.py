import tkinter as tk
from tkinter import scrolledtext
import subprocess
import threading

# Lista de enlaces a verificar
link_list = [
    "ax-argamedev-3dev.eastus.cloudapp.azure.com",
    "ax-argamevaldev.eastus.cloudapp.azure.com",
    "ax-chiphidev-3dev.eastus.cloudapp.azure.com",
    "ax-criletdev-3dev.eastus.cloudapp.azure.com",
    "ax-domletdev-3dev.eastus.cloudapp.azure.com",
    "ax-domrowdev-3dev.eastus.cloudapp.azure.com",
    "ax-domrowval-3dev.eastus.cloudapp.azure.com",
    "ax-gualetdev-3dev.eastus.cloudapp.azure.com",
    "ax-hndletdev-3dev.eastus.cloudapp.azure.com",
    "ax-nicletdev-3dev.eastus.cloudapp.azure.com",
    "ax-slvletdev-3dev.eastus.cloudapp.azure.com",
    "ax-panletdev-3dev.eastus.cloudapp.azure.com",
    "ax-dev2-3dev.eastus.cloudapp.azure.com",
    "ax-dev3-3dev.eastus.cloudapp.azure.com",
    "ax-dev4-3dev.eastus.cloudapp.azure.com",
    "ax-dev5-3dev.eastus.cloudapp.azure.com",
    "ax-dev6-3dev.eastus.cloudapp.azure.com",
    "ax-dev7-3dev.eastus.cloudapp.azure.com",
    "ax-usamlbdev-2dev.eastus.cloudapp.azure.com",
    "ax-ecumlbdev-2dev.eastus.cloudapp.azure.com",
    "ax-uruicldev-3dev.eastus.cloudapp.azure.com",
    "ax-uruiclgld-3dev.eastus.cloudapp.azure.com"
]

# Variable de control para detener
detener = False

def verificar_links():
    global detener
    detener = False
    resultado_text.delete(1.0, tk.END)
    total = len(link_list)
    respondieron = 0
    no_respondieron = 0

    # Desactivar botón de inicio y activar botón de detener
    boton_verificar.config(state=tk.DISABLED)
    boton_detener.config(state=tk.NORMAL)

    for link in link_list:
        if detener:
            resultado_text.insert(tk.END, "\n⛔ Verificación detenida por el usuario.\n", "warning")
            break

        resultado_text.insert(tk.END, f"Verificando el ping de {link}...\n")
        resultado_text.update_idletasks()

        result = subprocess.run(["ping", "-n", "4", link], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        if result.returncode != 0:
            resultado_text.insert(tk.END, f"{link} NO RESPONDE AL PING, VERIFICAR AMBIENTE.\n", "error")
            no_respondieron += 1
        else:
            resultado_text.insert(tk.END, f"{link} responde al ping.\n", "ok")
            respondieron += 1

        resultado_text.insert(tk.END, "_____________________________________________________________________________________________________________\n")
        resultado_text.update_idletasks()

    if not detener:
        resultado_text.insert(tk.END, "\n📋 RESUMEN FINAL:\n", "resumen")
        resultado_text.insert(tk.END, f"🔢 Total de ambientes: {total}\n", "info")
        resultado_text.insert(tk.END, f"✅ Respondieron al ping: {respondieron}\n", "ok")
        resultado_text.insert(tk.END, f"❌ No respondieron al ping: {no_respondieron}\n", "error")

        if no_respondieron > 0:
            resultado_text.insert(tk.END, "\n🔴 Hay ambientes que no están respondiendo. Revisar.\n", "error")
        else:
            resultado_text.insert(tk.END, "\n🟢 Todos los ambientes están respondiendo correctamente.\n", "ok")

    # Restaurar estado de los botones
    boton_verificar.config(state=tk.NORMAL)
    boton_detener.config(state=tk.DISABLED)

def iniciar_verificacion():
    thread = threading.Thread(target=verificar_links)
    thread.start()

def detener_verificacion():
    global detener
    detener = True

# Crear ventana principal
ventana = tk.Tk()
ventana.title("Verificador de ambientes 365")
ventana.state("zoomed") # Pantalla completa

# Caja de resultados
resultado_text = scrolledtext.ScrolledText(ventana, wrap=tk.WORD, font=("Consolas", 10))
resultado_text.pack(expand=True, fill="both", padx=10, pady=10)

# Estilos de colores
resultado_text.tag_config("error", foreground="red")
resultado_text.tag_config("ok", foreground="green")
resultado_text.tag_config("warning", foreground="orange")
resultado_text.tag_config("resumen", foreground="blue", font=("Consolas", 11, "bold"))
resultado_text.tag_config("info", foreground="black", font=("Consolas", 10, "bold"))

# Botones
frame_botones = tk.Frame(ventana)
frame_botones.pack(pady=10)

boton_verificar = tk.Button(frame_botones, text="Iniciar Verificación", font=("Arial", 12), command=iniciar_verificacion)
boton_verificar.pack(side=tk.LEFT, padx=10)

boton_detener = tk.Button(frame_botones, text="Detener", font=("Arial", 12), command=detener_verificacion, state=tk.DISABLED)
boton_detener.pack(side=tk.LEFT, padx=10)

# Tecla Escape para salir
ventana.bind("<Escape>", lambda e: ventana.destroy())

# Ejecutar la app
ventana.mainloop()
