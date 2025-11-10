using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.TextCore.Text;

[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(CharacterController))]
public class PlayerMovement : MonoBehaviour
{
    private Rigidbody rb;
    private PlayerControls playerInput;
    private CharacterController characterController;
    private Vector2 _lookInput;
    private bool mouseLocked;
    private float xRotation = 0f;
    [SerializeField] private float moveSpeed = 5f;
    [SerializeField] private float lookSpeed = 1f;
    [SerializeField] private float zoomSpeed = 10f;
    
    private void Awake()
    {
        characterController = GetComponent<CharacterController>();
        playerInput = new PlayerControls();
        playerInput.Player.Look.performed += ctx => _lookInput = ctx.ReadValue<Vector2>();
        playerInput.Player.Look.canceled += ctx => _lookInput = Vector2.zero;
        mouseLocked = false;
        Cursor.lockState = CursorLockMode.Locked;
    }
    
    private void OnEnable() => playerInput.Enable();
    private void OnDisable() => playerInput.Disable();
    
    private void Update()
    {
        if(!mouseLocked)
        {        
            Vector2 moveInput = playerInput.Player.Movement.ReadValue<Vector2>();
            Vector3 move = transform.right * moveInput.x + transform.forward * moveInput.y;
            characterController.Move(move * moveSpeed * Time.deltaTime);
            // Delta de mouse
            float mouseX = _lookInput.x * lookSpeed * Time.deltaTime;
            float mouseY = _lookInput.y * lookSpeed * Time.deltaTime;

            // Aplicar rotación directamente al GameObject
            transform.Rotate(Vector3.up * mouseX, Space.World);   // eje Y (horizontal)
            transform.Rotate(Vector3.left * mouseY, Space.Self);  // eje X (vertical)
        }
    }

    public void Lock_UnlockMouse()
    {
        if (!mouseLocked)
        {
            mouseLocked = true;
            Cursor.lockState = CursorLockMode.None;
        }
        else
        {
            mouseLocked = false;
            Cursor.lockState = CursorLockMode.Locked;
        }
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
