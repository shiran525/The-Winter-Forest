using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwordAttack : MonoBehaviour
{
    
    public GameObject enemy;
    // Start is called before the first frame update
    void Start()
    {
      
    }

    // Update is called once per frame
    void Update()
    {
        
    }

   void onCollisionEnter(Collision collisionInfo)
{
        if (collisionInfo.gameObject.tag == "WalkingDead")
        {
            Destroy(enemy);

        }
    }
}
