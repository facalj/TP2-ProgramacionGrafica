using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectoManager : MonoBehaviour
{
    public GameObject proyectorMouse;
    public GameObject proyectorPlayerCapsule;
    public GameObject proyectorPlayerBox;
    public GameObject proyectorPlayerSphere;

    void Start()
    {
        proyectorMouse.SetActive(false);
        proyectorPlayerCapsule.SetActive(false);
        proyectorPlayerBox.SetActive(false);
        proyectorPlayerSphere.SetActive(false);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.P))
        {
            proyectorMouse.SetActive(!proyectorMouse.activeSelf);
            Debug.Log("Proyector Mouse: " + (proyectorMouse.activeSelf ? "Activado" : "Desactivado"));
        }

        if (Input.GetKeyDown(KeyCode.U))
        {
            proyectorPlayerCapsule.SetActive(!proyectorPlayerCapsule.activeSelf);

            if (proyectorPlayerCapsule.activeSelf)
            {
                proyectorPlayerBox.SetActive(false);
                proyectorPlayerSphere.SetActive(false);
            }

            Debug.Log("Proyector Jugador: " + (proyectorPlayerCapsule.activeSelf ? "Activado" : "Desactivado"));
        }
        
        if (Input.GetKeyDown(KeyCode.I))
        {
            proyectorPlayerBox.SetActive(!proyectorPlayerBox.activeSelf);

            if (proyectorPlayerBox.activeSelf)
            {
                proyectorPlayerSphere.SetActive(false);
                proyectorPlayerCapsule.SetActive(false);
            }

            Debug.Log("Proyector Jugador: " + (proyectorPlayerBox.activeSelf ? "Activado" : "Desactivado"));
        }

        if (Input.GetKeyDown(KeyCode.O))
        {
            proyectorPlayerSphere.SetActive(!proyectorPlayerSphere.activeSelf);
            
            if (proyectorPlayerSphere.activeSelf)
            {
                proyectorPlayerBox.SetActive(false);
                proyectorPlayerCapsule.SetActive(false);
            }

            Debug.Log("Proyector Jugador: " + (proyectorPlayerSphere.activeSelf ? "Activado" : "Desactivado"));
        }
    }
}
