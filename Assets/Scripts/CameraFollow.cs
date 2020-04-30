using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public GameObject player;

    private Vector3 newPos = new Vector3();

    void FixedUpdate()
    {
        newPos.x = player.transform.position.x;
        newPos.y = ((player.transform.position.y) + 2f);
        newPos.z = ((player.transform.position.z) + 15f);

        transform.position = newPos;

    }
}