using UnityEngine;
using UnityEngine.UI;

public class ToonLightingUI : MonoBehaviour
{
    public Material ToonMaterial;
    public Slider LightIntensitySlider;
    public Slider ShininessSlider;
    public Slider NumberOfBandsSlider;
    public Toggle ModelToggle;

    void Start()
    {
        LightIntensitySlider.onValueChanged.AddListener(SetLightIntensity);
        ShininessSlider.onValueChanged.AddListener(SetShininess);
        NumberOfBandsSlider.onValueChanged.AddListener(SetNumberOfBands);
        ModelToggle.onValueChanged.AddListener(SetLightingModel);
    }

    void SetLightIntensity(float value)
    {
        ToonMaterial.SetFloat("_LightIntensity", value);
    }

    void SetShininess(float value)
    {
        ToonMaterial.SetFloat("_Shininess", value);
    }

    void SetNumberOfBands(float value)
    {
        ToonMaterial.SetFloat("_Bands", value);
    }

    void SetLightingModel(bool isBlinnPhong)
    {
        ToonMaterial.SetFloat("_IsBillinPhong", isBlinnPhong ? 1.0f : 0.0f);
    }
}
