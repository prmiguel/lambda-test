import axios from 'axios';

type Event = {a: string, b: number}

export function handler(event: Event): Promise<any> {
  console.log('==> ', event);
  return axios.get<any>("https://reqres.in/api/users").then((response: any) => {
    console.log(response.data.data);
    return Promise.resolve(response.data.data);
  });
  // return Promise.resolve(event);
}
