using UnityEngine;
using Cinemachine;

public sealed class CameraSwitcher : MonoBehaviour
{
    [Header("Virtual Cameras")]
    [SerializeField] private CinemachineVirtualCamera camCards;
    [SerializeField] private CinemachineVirtualCamera camModel;

    [Header("Model Camera Rotation")]
    [SerializeField] private Transform modelCameraPivot;
    [SerializeField] private float rotationSpeed = 90f;

    [Header("UI")]
    [SerializeField] private GameObject cardsCanvas;

    [Header("Priorities")]
    [SerializeField] private int activePriority = 20;
    [SerializeField] private int inactivePriority = 10;

    private bool isModelViewActive;

    private void Awake()
    {
        GoToCards();
    }

    private void Update()
    {
        if (!isModelViewActive) return;
        HandleModelCameraRotation();
    }

    public void GoToCards()
    {
        if (!Validate()) return;

        camCards.Priority = activePriority;
        camModel.Priority = inactivePriority;

        isModelViewActive = false;

        if (cardsCanvas != null)
            cardsCanvas.SetActive(true);
    }

    public void GoToModel()
    {
        if (!Validate()) return;

        camModel.Priority = activePriority;
        camCards.Priority = inactivePriority;

        isModelViewActive = true;

        if (cardsCanvas != null)
            cardsCanvas.SetActive(false);
    }

    private void HandleModelCameraRotation()
    {
        float direction = 0f;

        if (Input.GetKey(KeyCode.A)) direction = -1f;
        if (Input.GetKey(KeyCode.D)) direction = 1f;

        if (direction == 0f) return;

        modelCameraPivot.Rotate(
            Vector3.up,
            direction * rotationSpeed * Time.deltaTime,
            Space.World
        );
    }

    private bool Validate()
    {
        if (camCards == null || camModel == null || modelCameraPivot == null)
        {
            Debug.LogWarning("CameraSwitcher: Missing references.");
            return false;
        }

        return true;
    }
}
