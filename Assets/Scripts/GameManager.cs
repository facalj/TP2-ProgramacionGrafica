using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameSceneManager : MonoBehaviour
{
    public static GameSceneManager Instance { get; private set; }
    [SerializeField] private SceneSettingsSO sceneSettings;
    [SerializeField] TMPro.TextMeshProUGUI sceneNameText;
    private MaterialSettingsSO materialSettings;
    private int currentSceneIndex;
    private List<string> scenes;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject); 
        }
    }

    private void Start()
    {
        scenes = sceneSettings.scenes;
        FindScene(0);
        LoadScene(scenes[currentSceneIndex]);
    }
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.RightArrow))
        {
            GoToNextScene();
        }
        if (Input.GetKeyDown(KeyCode.LeftArrow))
        {
            GoToPreviousScene();
        }
    }
    private void OnEnable()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    private void OnDisable()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }
    
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        UpdateSceneNameUI(scene.name);
    }
    
    
    private void LoadScene(string sceneSelected)
    {
        if (IsSceneValid(sceneSelected))
        {
            SceneManager.LoadScene(sceneSelected);
        }
        else
        {
            Debug.LogError($"Scene not found: {sceneSelected}");
        }
    }
    
    private bool IsSceneValid(string sceneName)
    {
        for (int i = 0; i < SceneManager.sceneCountInBuildSettings; i++)
        {
            string path = SceneUtility.GetScenePathByBuildIndex(i);
            string name = System.IO.Path.GetFileNameWithoutExtension(path);

            if (name == sceneName)
                return true;
        }
        return false;
    }

    private int FindScene(int sceneIndex)
    {
        if (sceneIndex < 0)
        {
            currentSceneIndex = (currentSceneIndex - 1 + scenes.Count) % scenes.Count;
        }

        if (currentSceneIndex >= scenes.Count)
        {
            currentSceneIndex = (currentSceneIndex + 1) % scenes.Count;
        }
        return currentSceneIndex;
    }
    
    public void GoToNextScene()
    {
        currentSceneIndex++;
        FindScene(currentSceneIndex);
        LoadScene(scenes[currentSceneIndex]);
    }

    public void GoToPreviousScene()
    {
        currentSceneIndex--;
        FindScene(currentSceneIndex);
        LoadScene(scenes[currentSceneIndex]);
    }

    private void UpdateSceneNameUI(string sceneName)
    {
        sceneNameText.text = sceneName;
    }
}
